const express = require('express');
const bodyParser = require('body-parser');
const Users = [];
const app = express();
const cors=require("cors");
const corsOptions ={
   origin:'*', 
   credentials:true,            //access-control-allow-credentials:true
   optionSuccessStatus:200,
}

app.use(cors(corsOptions)) // Use this after the variable declaration


const { body, validationResult } = require('express-validator');

var db = require('./db');
var connection = db.connection
var mysql = require('mysql');



app.use(bodyParser.json());



app.get('/', (req, res) => {

    res.send('Community Api');

});


app.get('/SingleUser/:id', (req, res) => {

    connection.query('Select * FROM allusers WHERE userId = ?', [req.params.id], (err, rows, fields) => {
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


app.get('/HofUsers/:id', (req, res) => {

    connection.query('Select * FROM allusers WHERE userIsHeadID = ?', [req.params.id], (err, rows, fields) => {
        if (!err) {
            if (rows[0] == undefined) {

                res.status(200).send({ 'success': false, 'message': 'No child or other users found in db.' });

            }
            else {
                res.status(200).send({ 'success': true, 'data': rows });
            }

        }
        else

            console.log(err);
    })



});


app.get('/AllUsers', (req, res) => {


    connection.query('Select * FROM allusers', (err, rows, fields) => {
        if (!err)
            res.status(200).send({ 'success': true, 'data': rows });
        else

            console.log(err);
    })

});


app.post('/CreateUser', body('userEmail').isEmail(), body('userPassword').isLength({
    min: 6
}), body('userFirstName').isLength({
    min: 2
}), body('userMiddleName').exists(), body('userType').exists(), body('userLastName').isLength({
    min: 2
}),
    body('userAddress').exists(), body('userCellNumber').isLength({
        min: 2
    }), body('userDOB').exists(), body('userSpouseName').exists(), body('userSpouseNumber').exists(), body('userSpouseDOB').exists(), body('userIsHead').exists(), body('userIsHeadID').exists(), body('userPackageName').exists(), body('userPackageNumbers').exists(),
    (req, res) => {
        res.setHeader('Access-Control-Allow-Origin', '*');

        const errors = validationResult(req);
        if (!errors.isEmpty()) {
            return res.status(400).json({ 'success': false, 'message': 'User not saved', errors: errors.array() });
        }

        connection.query("SELECT COUNT(*) AS cnt FROM allusers WHERE userEmail = ?",
            [req.body.userEmail, req.body.userNumber], function (err, data) {

                if (err) {
                    console.log(err);
                }
                else {
                    if (data[0].cnt > 0) {
                        res.status(200).send({ 'success': false, 'message': 'User Email Already Exist.!' });
                    } else {
                        console.log(req.body);


                        connection.query("INSERT INTO allusers (userEmail, userPassword, userFirstName, userMiddleName, userLastName, userAddress, userDOB, userCellNumber, userSpouseName, userSpouseNumber, userSpouseDOB, userIsHead, userIsHeadID, userPackageName, userPackageNumber, userType) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?,?,?,?,?,?,?, ?)", [req.body.userEmail, req.body.userPassword, req.body.userFirstName, req.body.userMiddleName, req.body.userLastName, req.body.userAddress, req.body.userDOB, req.body.userCellNumber, req.body.userSpouseName, req.body.userSpouseNumber, req.body.userSpouseDOB, req.body.userIsHead, req.body.userIsHeadID, req.body.userPackageName, req.body.userPackageNumbers, req.body.userType], function (err, result) {
                            if (err) throw err
                                ;
                            console.log("Number of records inserted: " + result.affectedRows);
                            console.log(result);
                            res.status(200).send({ 'success': true, 'message': 'User Created Successfully.!', 'userId': result.insertId });
                        });

                    }
                }
            })
    });



app.listen(3000, function () {
    console.log('server is running on port 3000')
});
