const express = require('express');



const bodyParser = require("body-parser");
const { body, validationResult } = require('express-validator');
var db = require('./db');
var connection = db.connection


var mysql = require('mysql');

const app = express();

app.use(express.urlencoded({ extended: false }));


const user = [];


app.get('/users', function (req, res) {

    connection.query('Select * FROM users', (err, rows, fields) => {
        if (!err)
            res.status(200).send({ 'success': true, 'data': rows });
        else

            console.log(err);
    })

});


app.get('/user/:id', function (req, res) {

    connection.query('Select * FROM users WHERE userID = ?', [req.params.id], (err, rows, fields) => {
        if (!err) {
            if (rows[0] == undefined) {

                res.status(200).send({ 'success': false, 'message': 'No user found in db.' });

            }
            else {
                res.status(200).send({ 'success': true, 'data': rows });
            }

        }
        else

            console.log(err);
    })

});




app.post('/createUser',
    body('userEmail').isEmail(),
    body('userPassword').isLength({ min: 5, }),
    body('userName', 'userName is required').exists(),
    body('userNumber', 'userNumber is required').exists(),
    function (req, res) {
        const { authorization } = req.headers;
        console.log(req.headers);
        console.log(req.body);

        if (authorization && authorization == "123") {
            const errors = validationResult(req);
            if (!errors.isEmpty()) {
                return res.status(400).json({ errors: errors.array() });
            }
            console.log(req.body);
            console.log(req.body.userEmail);
            const checkUser = user.find((user) => user.userEmail == req.body.userEmail);
            console.log(checkUser);

            connection.query("SELECT COUNT(*) AS cnt FROM users WHERE userEmail = ? OR userNumber = ?",
                [req.body.userEmail, req.body.userNumber], function (err, data) {
                    if (err) {
                        console.log(err);
                    }
                    else {
                        if (data[0].cnt > 0) {
                            res.status(200).send({ 'success': false, 'message': 'User Email Already Exist.!' });
                        } else {
                            connection.query("INSERT INTO users (userEmail, userPassword, userName, userNumber) VALUES (?, ?, ?, ?)", [req.body.userEmail, req.body.userPassword, req.body.userName, req.body.userNumber], function (err, result) {
                                if (err) throw err;
                                console.log("Number of records inserted: " + result.affectedRows);
                                res.status(200).send({ 'success': true, 'message': 'User Created Successfully.!' });
                            });

                        }
                    }
                })



        }
        else {
            res.status(403).send({ 'message': 'Authorization failed.!' });
        }

    });



app.listen(3000, function () {
    console.log('server is running on port 3000')
});
