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

        const { generateKeyPair } = require('crypto');
        generateKeyPair('rsa', {
            modulusLength: 4096,
            publicKeyEncoding: {
                type: 'spki',
                format: 'pem'
            },
            privateKeyEncoding: {
                type: 'pkcs8',
                format: 'pem',
                cipher: 'aes-256-cbc',
                passphrase: req.body.password
            }

        }, (err, publicKey, privateKey) => {
            if (err) {
                console.log(err);
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
                rsa_pubblic: publicKey,
                rsa_private: privateKey,
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
                        message: 'An error occurred!'
                    })
                })
        });
    })
}

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
                        let token = jwt.sign({ id: user.userId, user: user.user }, 'g32hf.239Gamgi3))gmAG(mgoq', { expiresIn: '7d' });
                        /* TODO RSA pairKey
                        let buffer = "";
                        const CRYPTO = require('crypto');
                        console.log(user.rsa_private.toString('utf8'));
                        var privateKey = CRYPTO.createPrivateKey({
                            'key': user.rsa_private.toString('utf8'),
                            'format': 'pem',
                            'type': 'pkcs8',
                            'cipher': 'aes-256-cbc',
                            'passphrase': password
                        });

                        var hash = CRYPTO.privateDecrypt({
                            'key': privateKey,
                            'passphrase': password,
                            'cipher': 'aes-256-cbc',
                            'padding': CRYPTO.constants.RSA_PKCS1_PADDING
                        }, buffer).toString();
                        */
                        res.json({
                            userId: user.userId,
                            //publicKey: user.rsa_pubblic,
                            //privateKey: hash,
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
