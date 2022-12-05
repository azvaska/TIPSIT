import { userService } from '../_services';
import { router } from '../router';

const user = JSON.parse(localStorage.getItem('user')); // change??

const state = user
    ? { status: { loggedIn: true }, user }
    : { status: {}, user: null };

export const account = {
    namespaced: true,
    state,
};