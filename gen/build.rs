use std::fs::File;
use std::io::Write;
use std::path::Path;
use std::process::Command;

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
    writeln!(file, "# 2025 Crystal Ball Cup")?;

    for event in events.iter() {
        writeln!(file, "\n## {}", event.short)?;
        writeln!(file, "{}", event.precise)?;
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

    // Generate PDF slides using pandoc
    let output = Command::new("pandoc")
        .arg("-t")
        .arg("beamer")
        .arg("events.md")
        .arg("-o")
        .arg("events.pdf")
        .output()?;

    if !output.status.success() {
        eprintln!("pandoc failed: {:?}", output);
        return Err(std::io::Error::new(
            std::io::ErrorKind::Other,
            "pandoc command failed",
        ));
    }

    // Generate PDF for rules.md
    let output_rules = Command::new("pandoc")
        .arg("-t")
        .arg("beamer")
        .arg("rules.md")
        .arg("-o")
        .arg("rules.pdf")
        .arg("--pdf-engine=xelatex")
        .output()?;

    if !output_rules.status.success() {
        eprintln!("pandoc for rules.md failed: {:?}", output_rules);
        return Err(std::io::Error::new(
            std::io::ErrorKind::Other,
            "pandoc command for rules.md failed",
        ));
    }

    Ok(())
}
