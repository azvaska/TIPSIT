import express from 'express';
import bcrypt from 'bcrypt';
import jwt from 'jsonwebtoken';
import fs from 'fs';
import crypto from 'crypto';
import { nearestbacaro, bacaro_with_id, bacari_lists } from './bacari.js';
import { sequelize, Bacaro, User } from './db.js';
import isValid from './util.js';
import AdminJS from 'adminjs';
import AdminJSExpress from '@adminjs/express';
import * as AdminJSSequelize from '@adminjs/sequelize';
import HttpStatusCode from './HttpStatusCode.js';
import fileUpload from 'express-fileupload';
import pngToJpeg from 'png-to-jpeg';

const saltRounds = 10;
const app = express();

const __dirname = '/home/ubuntu/bacari/server';

const DEFAULT_ADMIN = {
    email: 'a@a.com',
    password: 'a',
}



AdminJS.registerAdapter({
    Resource: AdminJSSequelize.Resource,
    Database: AdminJSSequelize.Database,
})

const auth_configus = {
    authenticate: async (email, password) => {
        if (!email || !password) {
            return null;
        }
        const user = await User.findOne({ where: { email } });
        if (user === null) {
            console.log('Invalid credentials');
            return null;
        }
        if (user.is_admin === false) {
            return null;
        }


        let result = await bcrypt.compare(password, user.password);
        if (!result) {
            console.log('Invalid credentials');
            return null;
        }
        return { email: user.email, id: user.id };


    },
    cookieName: 'adminJS-session',
    cookiePassword: "Secret",

};
const adminOptions = {
    // TODO when update change also in location with trigger or sequel hooks
    resources: [User, {
        resource: Bacaro,
        options: {
            properties: {
                location: {
                    isVisible: {
                        edit: false,
                        show: false,
                        list: false,
                        filter: false,
                    },

                }
            }
        }
    }],
    rootPath: '/admin',
}
const admin = new AdminJS(adminOptions)

const adminRouter = AdminJSExpress.buildAuthenticatedRouter(admin, auth,
    null,)
app.use(admin.options.rootPath, adminRouter)
console.log(admin.options.rootPath)
app.use(express.json());
app.use(express.urlencoded({ extended: true }));
app.use(fileUpload({
    createParentPath: true, limits: {
        fileSize: 2 * 1024 * 1024 * 1024 //2MB max file(s) size
    },
}));

// app.use(auth({
//     issuer: 'http://204.216.223.6',
//     audience: 'http://204.216.223.6',
//     secret: TOKEN_SECRET,
//     tokenSigningAlg: 'HS256',
// }).unless({ path: ['/signup','/login'] }));
const port = 3000;


// TODO da spostare in un file a parte
function generateAccessToken(id) {
    return jwt.sign({
        'sub': id,
        'aud': 'http://204.216.223.6',
        'jti': crypto.randomBytes(16).toString('hex'),
    }, TOKEN_SECRET, { expiresIn: '12d' });
    // return jwt.sign(username, "idroscimmia", { expiresIn: 60 * 60 });
}

// TODO da spostare in un file a parte
function authenticateToken(req, res, next) {
    const authHeader = req.headers['authorization'];
    const token = authHeader && authHeader.split(' ')[1];

    if (token == null) return res.sendStatus(HttpStatusCode.UNAUTHORIZED);

    jwt.verify(token, TOKEN_SECRET, (err, user) => {
        console.log(err);
        if (err) return res.sendStatus(HttpStatusCode.FORBIDDEN);
        User.findByPk(user.sub).then(user => {
            if (user === null) {
                return res.sendStatus(HttpStatusCode.FORBIDDEN);
            }
            req.user = user;
            next();
        });
    });
}


// app.get('/', (req, res) => {
//     con.query("SELECT * FROM users", (err, result, fields) => {
//         if (err) throw err;
//         res.send(result);
//     });
// });



app.post('/signup', async (req, res) => {
    if (!req.body) return res.sendStatus(HttpStatusCode.BAD_REQUEST);

    const username = req.body.username;
    const password = req.body.password;
    const email = req.body.email;

    if (!isValid(username) || !isValid(password) || !isValid(email)) {
        return res.status(HttpStatusCode.BAD_REQUEST).send("missing parameters");
    }

    const encryptedPassword = await bcrypt.hash(password, saltRounds);
    User.create({
        username: username,
        email: email,
        password: encryptedPassword
    }).then(user => {
        res.json(generateAccessToken(user.id));
    }).catch(err => {
        console.error(err);
        res.status(HttpStatusCode.BAD_REQUEST).send("an error occurred");
    });
});


app.post('/login', async (req, res) => {
    console.log('POST /login');
    if (!req.body) return res.sendStatus(HttpStatusCode.BAD_REQUEST);
    // get username and password from request
    const username = req.body.username;
    const email = req.body.email;
    const password = req.body.password;
    console.log(req.body);
    console.log('username:', username, 'email:', email, 'password:', password);

    // check if username and password are present
    if ((!isValid(username) && !isValid(email)) || !isValid(password)) {
        res.status(HttpStatusCode.BAD_REQUEST).send('missing parameters');
        return;
    }

    let isUsername = isValid(username);

    // get user from database

    let not_null = isUsername ? username : email;
    User.findOne({
        where: {
            [isUsername ? 'username' : 'email']: not_null
        }
    }).then(user => {
        if (user == null) {
            res.status(HttpStatusCode.BAD_REQUEST).send('ERROR wrong credentials');
            return;
        }
        bcrypt.compare(password, user.password).then(isPasswordCorrect => {
            if (!isPasswordCorrect) {
                res.status(HttpStatusCode.BAD_REQUEST).send('ERROR wrong credentials');
                return;
            }
            res.json(generateAccessToken(user.id));
        });
    }).catch(err => {
        console.error(err);
        res.status(HttpStatusCode.BAD_REQUEST).send('an error occurred');
    });
});

app.get('/bacari', authenticateToken, bacari_lists);
app.get('/get_total_score', authenticateToken, get_score_user);
app.get('/get_leaderboard_people', authenticateToken, get_leaderboard);
app.get('/get_leaderboard_bacari', authenticateToken, get_leaderboard_bacari);

app.get('/nearest_bacaro/:lat/:lng/:radius', authenticateToken, nearestbacaro);
app.get('/bacaro/:id', authenticateToken, bacaro_with_id);
app.get('/add_score/:id', authenticateToken, add_score);

app.patch('/update_user', authenticateToken, (req, res) => {
    
});


async function convertToJpg(data) {
    return pngToJpeg({ quality: 90 })(data).then(output => {
        return output;
    });
}

async function saveImage(data, path) {
    return fs.writeFile(__dirname + '/images/' + path + '.jpg', data, function (err) {
        return Boolean(err);
    });
}

app.post('/upload', authenticateToken, (req, res) => {
    // if (!req.body) return res.sendStatus(HttpStatusCode.BAD_REQUEST);

    // curl -i -F file=@{path_image} http://204.216.223.6:3000/upload -X POST -H "Authorization: Bearer {token}"
    console.log(req.files);
    User.findByPk(req.user.id).then(user => {
        if (user == null) return res.status(HttpStatusCode.BAD_REQUEST).send('user not found');

        if (!req.files || (!req.files.file && !req.files.image)) return res.status(HttpStatusCode.BAD_REQUEST).send('No files were uploaded');

        const file = req.files.file || req.files.image;

        let type = file.name.split('.');
        type = type[type.length - 1].toLowerCase();

        switch (type) {
            case 'jpg':
            case 'jpeg':
            case 'png':
                user.image = true;
                user.save().then(() => {
                    // save file
                    if (type === 'png') {
                        convertToJpg(file.data).then(output => {
                            saveImage(output, user.id).then(() => {
                                return res.sendStatus(HttpStatusCode.OK);
                            });
                        });
                    } else {
                        // save file
                        saveImage(file.data, user.id).then(() => {
                            return res.sendStatus(HttpStatusCode.OK);
                        });
                    }
                });
                break;
            default:
                console.log("unsupported media type");
                return res.status(HttpStatusCode.UNSUPPORTED_MEDIA_TYPE).send('unsupported media type');
        }
    });
});

app.get('/image/:id', authenticateToken, (req, res) => {
    // check parameter
    const id = req.params.id;
    if (!isValid(id)) return res.sendStatus(HttpStatusCode.BAD_REQUEST);

    User.findByPk(id).then(async user => {
        if (user == null) return res.status(HttpStatusCode.BAD_REQUEST).send('user not found');

        if (!user.image) return res.status(HttpStatusCode.NOT_FOUND).send('user does not have an image');

        res.contentType('image/jpg');

        fs.readFile(__dirname + '/images/' + user.id + '.jpg', (err, data) => {
            if (err) {
                if (err.code === 'ENOENT') {
                    console.error('myfile does not exist');
                    return;
                }
            }
            res.send(data);
        });
    });
});

app.get('/profile', authenticateToken, (req, res) => {
    // check parameter
    User.findByPk(req.user.id).then(async user => {
        if (user == null) return res.status(HttpStatusCode.BAD_REQUEST).send('user not found');

        let resUser = Object.keys(user.dataValues)
            .filter((key) => !key.includes('password'))
            .reduce((cur, key) => { return Object.assign(cur, { [key]: user[key] }) }, {});

        res.json(resUser);
    });
});

app.get('/user/:id', authenticateToken, (req, res) => {
    // check parameter
    const id = req.params.id;
    if (!isValid(id)) return res.sendStatus(HttpStatusCode.BAD_REQUEST);

    User.findByPk(id).then(async user => {
        if (user == null) return res.status(HttpStatusCode.BAD_REQUEST).send('user not found');

        let resUser = Object.keys(user.dataValues)
            .filter((key) => !key.includes('password'))
            .reduce((cur, key) => { return Object.assign(cur, { [key]: user[key] }) }, {});

        res.json(resUser);
    });
});

app.listen(port, () => {
    console.log(`Example app listening on port ${port}`);
});
