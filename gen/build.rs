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

fn generate_pdf(
    input_md: &str,
    output_pdf: &str,
    pdf_engine: Option<&str>,
) -> std::io::Result<()> {
    let mut command = Command::new("pandoc");
    command
        .arg("-t")
        .arg("beamer")
        .arg(input_md)
        .arg("-o")
        .arg(output_pdf);

    if let Some(engine) = pdf_engine {
        command.arg(format!("--pdf-engine={}", engine));
    }

    let output = command.output()?;

    if !output.status.success() {
        eprintln!("pandoc failed for {}: {:?}", input_md, output);
        return Err(std::io::Error::new(
            std::io::ErrorKind::Other,
            format!("pandoc command failed for {}", input_md),
        ));
    }

    Ok(())
}

fn main() -> std::io::Result<()> {
    println!("cargo:rerun-if-changed=../lib/src/lib.rs");
    println!("cargo:rerun-if-changed=gen/rules.md");
    println!("cargo:rerun-if-changed=gen/desmos-graph.png");

    let events: Vec<Event> = EVENTS
        .iter()
        .map(|const_event| Event::new(const_event.short, const_event.precise))
        .collect();

    write_json_file("events.json", &events)?;
    write_markdown_file("events.md", &events)?;

    generate_pdf("events.md", "events.pdf", None)?;
    generate_pdf("rules.md", "rules.pdf", Some("xelatex"))?;

    Ok(())
}
