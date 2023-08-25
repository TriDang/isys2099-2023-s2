const express = require("express");
const bodyParser = require("body-parser");
const mysql = require("./lib");
const app = express();
const port = 4000;

app.use(express.static("public"));
app.use(bodyParser.urlencoded({ extended: false }));

app.get("/", (req, res) => {
  res.redirect("/login.html");
});

app.post("/", (req, res) => {
  const { username, password } = req.body;
  mysql.login(username, password, (result) => {
    if (result && result.length > 0) {
      res.send(`Welcome ${result[0].username}`);
    } else {
      res.send('Username/password is incorrect');
    }
  });
});

app.listen(port, () => {
  console.log(`Example app listening on port ${port}`);
});
