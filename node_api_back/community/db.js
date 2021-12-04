const mysql = require('mysql');

var mysqlConnection = mysql.createConnection({
    host: 'localhost',
    user: 'root',
    password: '',
    database: 'users'
});

mysqlConnection.connect((err) => {
    if(!err){
        console.log('User DB connection success');
    }
    else{
        console.log('User DB connection have errro which is : ' +JSON.stringify(err));
    }
});

module.exports = {
    connection : mysql.createConnection({
        host: 'localhost',
        user: 'root',
        password: '',
        database: 'users'
    })
} 
