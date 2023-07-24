import { Sequelize } from 'sequelize';
import dotenv from 'dotenv';
import * as path from 'path';
import { fileURLToPath } from 'url';
import { dirname } from 'path';
import bcrypt from 'bcrypt';

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);
dotenv.config({ path: path.join(__dirname, '.env') });

export const sequelize = new Sequelize(process.env.DB, process.env.USER_DB, process.env.PASSWORD, {
    host: process.env.HOST,
    dialect: process.env.DIALECT,
});
// User.create({username: 'a', email: 'a@a.c', password: 'a', is_admin: true})

export const User = sequelize.define('users', {
    id: {
        type: Sequelize.UUID,
        defaultValue: Sequelize.UUIDV4,
        primaryKey: true
    },
    username: { type: Sequelize.STRING(32), allowNull: false },
    email: { type: Sequelize.STRING(64), unique: true, allowNull: false },
    password: { type: Sequelize.STRING(80), allowNull: false },
    is_admin: { type: Sequelize.BOOLEAN, allowNull: false, defaultValue: false },
    image: { type: Sequelize.BOOLEAN, allowNull: false, defaultValue: false }
});

export const Bacaro = sequelize.define('bacari', {
    id: {
        type: Sequelize.UUID,
        defaultValue: Sequelize.UUIDV4,
        primaryKey: true,
    },
    name: { type: Sequelize.STRING(255), allowNull: false, unique: true, },
    lat: { type: Sequelize.DOUBLE, allowNull: false },
    lng: { type: Sequelize.DOUBLE, allowNull: false },
    location: { type: Sequelize.GEOMETRY('POINT'), allowNull: false },
}, {
    hooks:{
        beforeValidate(instance, options) {
            console.log("before validate");
            console.log(instance.lat, instance.lng);
            instance.location = {type: 'Point', coordinates: [instance.lat, instance.lng]};
        },
        beforeSave(instance, options) {
            console.log("before save");
            console.log(instance.lat, instance.lng,instance.location);
        },

    },
    freezeTableName: true,
    timestamps: false,
});
export const Score = sequelize.define('scores', {
    id: {
        type: Sequelize.INTEGER,
        autoIncrement: true, primaryKey: true,
    },
    value: { type: Sequelize.INTEGER, allowNull: false },
}, {
    freezeTableName: true,
    timestamps: true,
});

User.hasMany(Score);
Bacaro.hasMany(Score);
Score.belongsTo(User);
Score.belongsTo(Bacaro);
sequelize.sync();
/*
sequelize.sync({force:true}).then(async () => {
    User.create({username: 'a', email: 'a@a.c', password: await bcrypt.hash("a", 10), is_admin: true});
    User.create({username: 'toni', email: 'toni@toni', password: await bcrypt.hash("toni", 10), is_admin: false});
    User.create({username: 'qwer', email: 'qwer@qwer', password: await bcrypt.hash("qwer", 10), is_admin: false});

    Bacaro.create({name: 'Bacaro Risorto Castello', lat: 45.434974, lng:12.342632, location: {type: 'Point', coordinates: [45.434974, 12.342632]}})
    .then((bacaro) => {console.log('Bacaro created:', bacaro.toJSON());});
    Bacaro.create({name: 'Cicchetteria venexiana da Luca e Fred', lat: 45.443636, lng: 12.326209, location: {type: 'Point', coordinates: [45.443636, 12.326209]}})
    .then((bacaro) => {console.log('Bacaro created:', bacaro.toJSON());});
    Bacaro.create({name: 'IDROSCIMMIA MEGAGALATTICA guardate monkay spin idro scimmiooooo', lat: 45.4486, lng: 12.3212, location: {type: 'Point', coordinates: [45.434974, 12.342632]}})
    .then((bacaro) => {console.log('Bacaro created:', bacaro.toJSON());});
});
*/


// module.exports = { sequelize, User, Bacaro };