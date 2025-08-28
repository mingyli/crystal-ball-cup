export class Explorer {
  constructor(db) {
    this.db = db;
  }

  static async loadDb() {
    const SQL = await initSqlJs({
      locateFile: (file) =>
        `https://cdnjs.cloudflare.com/ajax/libs/sql.js/1.8.0/${file}`,
    });

    const response = await fetch("crystal.db");
    const buffer = await response.arrayBuffer();
    const db = new SQL.Database(new Uint8Array(buffer));
    return new Explorer(db);
  }

  executeQuery(query) {
    const queryResults = document.getElementById("query-results");
    const queryError = document.getElementById("query-error");
    queryError.textContent = "";
    queryResults.innerHTML = "";

    try {
      const res = this.db.exec(query);

      if (res.length === 0) {
        queryResults.innerHTML = "<tr><td>No results</td></tr>";
        return;
      }

      res.forEach((table) => {
        const headerRow = document.createElement("tr");
        table.columns.forEach((col) => {
          const th = document.createElement("th");
          th.textContent = col;
          headerRow.appendChild(th);
        });
        queryResults.appendChild(headerRow);

        table.values.forEach((row) => {
          const dataRow = document.createElement("tr");
          row.forEach((val) => {
            const td = document.createElement("td");
            td.textContent = val;
            dataRow.appendChild(td);
          });
          queryResults.appendChild(dataRow);
        });
      });
    } catch (err) {
      queryError.textContent = err.message;
      console.log(err);
    }
  }

  initializeDatabaseExplorer() {
    const queryEditor = document.getElementById("query-editor");
    const runQueryBtn = document.getElementById("run-query-btn");

    runQueryBtn.addEventListener("click", () => {
      const query = queryEditor.value;
      this.executeQuery(query);
    });

    queryEditor.addEventListener("keydown", (event) => {
      if (event.ctrlKey && event.key === "Enter") {
        event.preventDefault();
        const query = queryEditor.value;
        this.executeQuery(query);
      }
    });

    const query = queryEditor.value;
    this.executeQuery(query);
  }
}
