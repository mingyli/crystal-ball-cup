use std::fs::File;
use std::io::Write;
use std::path::Path;

use mylib::{Event, EVENTS};

fn write_json_file<P: AsRef<Path>>(
    filename: P,
    events: &[Event],
) -> std::io::Result<()> {
    let mut file = File::create(filename)?;
    let events_json = serde_json::to_string_pretty(&events).unwrap();
    writeln!(file, "{}", events_json)?;
    Ok(())
}

fn write_markdown_file<P: AsRef<Path>>(
    filename: P,
    events: &[Event],
) -> std::io::Result<()> {
    let mut file = File::create(filename)?;
    writeln!(file, "# Events")?;
    writeln!(file, "")?;

    for event in events {
        writeln!(file, "## {}", event.short)?;
        writeln!(file, "")?;
        writeln!(file, "{}", event.precise)?;
        writeln!(file, "")?;
    }

    Ok(())
}

fn main() -> std::io::Result<()> {
    println!("cargo:rerun-if-changed=../lib/src/lib.rs");

    let events: Vec<Event> = EVENTS
        .iter()
        .map(|const_event| Event::new(const_event.short, const_event.precise))
        .collect();

    write_json_file("events.json", &events)?;
    write_markdown_file("events.md", &events)?;

    Ok(())
}