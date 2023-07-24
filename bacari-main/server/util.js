const isValid = (p, type = 'string') => {
    if (p == null || p == '') {
        return false;
    }
    if (type == 'int') {
        p = parseInt(p);
        return p != null;
    } else if (type == 'float') {
        p = parseFloat(p);
        return p != null;
    }
    return p != null;
}
export default isValid;