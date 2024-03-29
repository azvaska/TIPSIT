const User = require('../models/User.js');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const uuid = require('uuid');

const register = (req, res, next) => {
    bcrypt.hash(req.body.password, 10, function (err, hashedPass) {
        if (err) {
            res.json({
                error: err
            });
            return;
        }

        
            let user = new User({
                user: req.body.user,
                email: req.body.email,
                password: hashedPass,
                userId: generateUserId(),
                block: []
            })

            user.save()
                .then(user => {
                    res.json({
                        message: 'User Added Successfully!'
                    })
                })
                .catch(err => {
                    res.json({
                        message: 'An error occurred!' + err
                    })
                })
        });
    };

const login = (req, res, next) => {
    let username = req.body.username;
    let password = req.body.password;

    User.findOne({ user: username })
        .then(user => {
            if (user) {
                bcrypt.compare(password, user.password, function (err, result) {
                    if (err) {
                        res.json({
                            error: err,
                        })
                    }
                    if (result) {
                        let token = jwt.sign({ id: user.userId, user: user.user }, 'g32hf.239Gamgi3))gmAG(mgoq', { expiresIn: '14d' });

                        res.json({
                            userId: user.userId,

                            message: 'Login successful!',
                            token
                        })
                    } else {
                        res.json({
                            message: 'Password does not matched!'
                        })
                    }
                });
            } else {
                res.json({
                    message: 'User Not Found'
                })
            }
        })
}

function generateUserId() {
    return uuid.v4();
}

module.exports = {
    register, login
}
