function login(username, password, callback) {
  const mysql = require("mysql");
  const connection = mysql.createConnection({
    host: "localhost",
    user: "app_user",
    password: "password",
    database: "app",
  });

  connection.connect((err) => {
    if (err) {
      console.error("error connecting: " + err.stack);
      return;
    }

    // get username and password    
    connection.query(`SELECT * FROM users WHERE username = '${username}' AND password = '${password}'`, (err, results) => {
      if (err) {
        console.error("error: " + err.stack);
        return;
      }
      callback(results);
    });

    // connection.end((err) => {
    //   if (err) {
    //     console.error("error connecting: " + err.stack);
    //     return;
    //   }
    //   console.log("Finished");
    // });
  });
}
module.exports = { login };
