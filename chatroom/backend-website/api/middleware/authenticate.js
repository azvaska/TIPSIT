const jwt = require('jsonwebtoken');

const authenticate = (req, res, next) => {
    try {
        const token = req.body.Authorization;
        const decoded = jwt.verify(token, 'g32hf.239Gamgi3))gmAG(mgoq');

        req.user = decoded;
        
        res.json({
            message: 'Authentication OK!'
        })

    } catch(error) {
        res.json({
            message: 'Authentication failed!'
        })
    }
}

module.exports = authenticate;
