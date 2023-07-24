import { sequelize, Bacaro, User, Score } from './db.js';
import { QueryTypes,Op } from 'sequelize';
import isValid from './util.js';
import HttpStatusCode from './HttpStatusCode.js';

const nearestbacaro = async (req, res) => {
    const lat = parseFloat(req.params.lat);
    const lng = parseFloat(req.params.lng);
    const radius = parseFloat(req.params.radius); //radius in meters around the point (lat, lng) to get all the bacari
    if (!isValid(lat, 'float') || !isValid(lng, 'float') || !isValid(radius, 'float')) {
        res.status(HttpStatusCode.FORBIDDEN).send("missing parameters");
        return;
    }
    let result = await sequelize.query(`SELECT b.*, ST_distance_sphere(location, ST_GeomFromText('POINT(${lat} ${lng})')) AS distance FROM bacari b WHERE ST_distance_sphere(location, ST_GeomFromText('POINT(${lat} ${lng})'))<=:rad ORDER BY distance DESC;`,
        {
            replacements: { rad: radius },
            type: QueryTypes.SELECT,
            model: Bacaro,
            mapToModel: true,
        });
    res.json(result);
}


const bacaro_with_id = (req, res) => {
    const b64_id = req.params.id;
    if (!isValid(b64_id)) return res.status(HttpStatusCode.FORBIDDEN).send("missing parameters");
    const id = Buffer.from(b64_id, 'base64').toString('utf8');

    Bacaro.findByPk(id).then(bacaro => {
        if (bacaro == null) return res.status(HttpStatusCode.FORBIDDEN).send("bacaro not found");
        res.json(bacaro);
    });

};

const bacari_lists = async (req, res) => {
    let bacari = await Bacaro.findAll();
    res.json(bacari);
}

const add_score = async (req, res) => {
    const b64_id = req.params.id;
    const score = 1; 
    if (!isValid(b64_id) || !isValid(score, 'float')) return res.status(HttpStatusCode.FORBIDDEN).send("missing parameters");
    const id = Buffer.from(b64_id, 'base64').toString('utf8');
    console.log(id);
    var two_h_ago = new Date();

    two_h_ago.setHours(two_h_ago.getHours() - 2);
    Bacaro.findByPk(id).then(async bacaro => {
        if (bacaro == null) return res.status(HttpStatusCode.FORBIDDEN).send("bacaro not found");
        Score.findOne({ where: { bacariId: bacaro.id, userId: req.user.id,createdAt:{
            [Op.lt]: new Date(),
            [Op.gt]: two_h_ago
        }}}).then(async score_instance => {
            if (score_instance != null) return res.status(HttpStatusCode.FORBIDDEN).send("score already added");
            let sc = await Score.create({
                bacariId: bacaro.id,
                userId: req.user.id,
                value: score,
            });
    
            res.send("OK");
        });

    });
}

const get_score_user = async (req, res) => {
    Score.sum('value', { where: { userId: req.user.id } }).then(result => {
        res.json(result);
    });
}

const get_leaderboard = async (req, res) => {
    let result = await sequelize.query(`SELECT u.username, SUM(s.value) AS score FROM scores s RIGHT JOIN users u ON s.userId=u.id GROUP BY u.id ORDER BY score DESC LIMIT 50;`,
        {
            type: QueryTypes.SELECT,
        });
    res.json(result);
};

const get_leaderboard_bacari = async (req, res) => {
    let result = await sequelize.query(`SELECT b.name, SUM(s.value) AS score FROM scores s RIGHT JOIN bacari b ON s.bacariId=b.id GROUP BY b.id ORDER BY score DESC LIMIT 50;`,
        {
            type: QueryTypes.SELECT,
        });
    res.json(result);
};


export { bacaro_with_id, nearestbacaro, bacari_lists, add_score, get_score_user, get_leaderboard, get_leaderboard_bacari };