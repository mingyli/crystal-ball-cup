The project uses `dune` for its build system. Run `dune build` to build the
project. Run `dune runtest` to run the tests. Since the build is likely already
running, run `dune diagnostics` to query the status of the build.

The project runs on the ocaml web framework `bonsai`. Some documentation for it
can be found at [bonsai.red](https://bonsai.red).

Respondents are given events, and for each event a respondent's response is a
probability that the event will occur. Each outcome has an outcome of pending,
yes, or no. Respondents are scored according to their responses.
