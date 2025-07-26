use clap::{Parser, Subcommand};
use mylib::{Event, EVENTS};
use serde_json;

#[derive(Parser)]
#[clap(author, version, about)]
struct Cli {
    #[clap(subcommand)]
    command: Command,
}

#[derive(Subcommand)]
enum Command {
    /// Dump the events.
    Dump {},
    /// Write the events out in markdown format.
    Markdown {},
}

fn main() {
    // At runtime, convert the compile-time definitions into the runtime Event
    // type.
    let events: Vec<Event> = EVENTS
        .iter()
        .map(|const_event| Event::new(const_event.short, const_event.precise))
        .collect();

    let cli = Cli::parse();
    match cli.command {
        Command::Dump {} => {
            for event in &events {
                println!("{}", serde_json::to_string(event).unwrap());
            }
        }
        Command::Markdown {} => {
            for event in &events {
                println!("## {}", event.short);
                println!("\n{}", event.precise);
                println!();
            }
        }
    }
}
