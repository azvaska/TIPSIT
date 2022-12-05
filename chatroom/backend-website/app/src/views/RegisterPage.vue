<template>
    <div class="grid">
        <form @submit.prevent="handleSubmit(name, mail, pass)" class="form login">
            <div class="form__field">
                <label for="username">
                    <svg class="icon">
                        <use xmlns:xlink="http://www.w3.org/1999/xlink" xlink:href="#user">
                        <symbol id="user" viewBox="0 0 1792 1792">
                            <path d="M1600 1405q0 120-73 189.5t-194 69.5H459q-121 0-194-69.5T192 1405q0-53 3.5-103.5t14-109T236 1084t43-97.5 62-81 85.5-53.5T538 832q9 0 42 21.5t74.5 48 108 48T896 971t133.5-21.5 108-48 74.5-48 42-21.5q61 0 111.5 20t85.5 53.5 62 81 43 97.5 26.5 108.5 14 109 3.5 103.5zm-320-893q0 159-112.5 271.5T896 896 624.5 783.5 512 512t112.5-271.5T896 128t271.5 112.5T1280 512z"></path>
                        </symbol>
                        </use>
                    </svg>
                </label>
                <span class="hidden">Username</span>
                <input type="text" v-model="name" name="username" class="form__input" placeholder="Username" />
            </div>
            <div class="form__field">
                <label htmlFor="email">
                    <svg class="icon" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="#363b41" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M4 4h16c1.1 0 2 .9 2 2v12c0 1.1-.9 2-2 2H4c-1.1 0-2-.9-2-2V6c0-1.1.9-2 2-2z"></path><polyline points="22,6 12,13 2,6"></polyline></svg>
                </label>
                <span class="hidden">Email</span>
                <input type="text" v-model="mail" name="email" class="form__input"  placeholder="Email" />
            </div>
            <div class="form__field">
                <label htmlFor="password">
                    <svg class="icon">
                        <use xmlns:xlink="http://www.w3.org/1999/xlink" xlink:href="#lock">
                            <symbol id="lock" viewBox="0 0 1792 1792">
                                <path d="M640 768h512V576q0-106-75-181t-181-75-181 75-75 181v192zm832 96v576q0 40-28 68t-68 28H416q-40 0-68-28t-28-68V864q0-40 28-68t68-28h32V576q0-184 132-316t316-132 316 132 132 316v192h32q40 0 68 28t28 68z"></path>
                            </symbol>
                        </use>
                    </svg>
                    <span class="hidden">Password</span>
                </label>
                <input type="password" v-model="pass" name="password" class="form__input" placeholder="Password" />
            </div>
            <div class="form__field">
                <input type="submit" :disabled="loggingIn" value="Sign up">
            </div>
        </form>
        <p class="text--center">Do you have an account? <router-link to="/login" class="btn btn-link">Sign in</router-link></p>
    </div>
</template>

<script>

const axios = require('axios').default;
const qs = require('qs');
import router from '@/router'

export default {
    mounted () {
        document.body.classList.add('sing')
        document.cookie = "Authorization= ;expires=Thu, 01 Jan 1970 00:00:01 GMT";
    },
    unmounted () {
        document.body.classList.remove('sing')
    },
    data () {
        return {
            submitted: false,
            registering: false
        }
    },
    methods: {
        handleSubmit(name, mail, pass) {
            this.submitted = true;
            this.registering = true;

            axios.post('http://localhost:3080/api/register', qs.stringify({
                    user: name,
                    email: mail,
                    password: pass
            }
            ))
            .then(function (res) {
                console.log(res);
                axios.post('http://localhost:3080/api/login', qs.stringify({
                    username: name,
                    password: pass
                }))
                .then(function (res) {
                    const token = res.data.token;

                    // calc cookie expiration date
                    var now = new Date();
                    var time = now.getTime();
                    var expireTime = time + 7*24*60*60*1000;
                    now.setTime(expireTime);

                    document.cookie = `Authorization=${token}; expires=${now.toUTCString()}; path=/`;

                    if(res.status == 200) {
                        window.pubblicKey = res.data.publicKey;
                        window.privateKey = res.data.privateKey;
                    
                        router.push({ name: 'Home', params: { userId: res.data.userId}})
                    }
                })
            })
            .catch(function (error) {
                console.log(error);
            });

        }
    }
};

</script>

<style lang="scss">
.grid {
 margin-left:auto;
 margin-right:auto;
 max-width:320px;
 max-width:20rem;
 width:90%
}
.hidden {
 border:0;
 clip:rect(0 0 0 0);
 height:1px;
 margin:-1px;
 overflow:hidden;
 padding:0;
 position:absolute;
 width:1px
}
.icons {
 display:none
}
.icon {
 display:inline-block;
 fill:#606468;
 font-size:16px;
 font-size:1rem;
 height:1em;
 vertical-align:middle;
 width:1em
}
.sing {
	background-color: #2c3338;
	color: #606468;
	font-family: open sans,sans-serif;
	font-size: 14px;
	font-size: .875rem;
	font-weight: 400;
	height: 100%;
	line-height: 1.5;
	margin: 0;
	min-height: 100vh;
    -webkit-box-align: center;
	-ms-flex-align: center;
	align-items: center;
	display: -webkit-box;
	display: -ms-flexbox;
	display: flex;
	-webkit-box-orient: vertical;
	-webkit-box-direction: normal;
	-ms-flex-direction: column;
	flex-direction: column;
	-webkit-box-pack: center;
	-ms-flex-pack: center;
	justify-content: center;
}
a {
 color:#eee;
 outline:0;
 text-decoration:none
}
a:focus,
a:hover {
 text-decoration:underline
}
input {
 background-image:none;
 border:0;
 color:inherit;
 font:inherit;
 margin:0;
 outline:0;
 padding:0;
 -webkit-transition:background-color .3s;
 transition:background-color .3s
}
input[type=submit] {
 cursor:pointer
}
.form {
 margin:-14px;
 margin:-.875rem
}
.form input[type=password],
.form input[type=text],
.form input[type=submit] {
 width:100%
}
.form__field {
 display:-webkit-box;
 display:-ms-flexbox;
 display:flex;
 margin:14px;
 margin:.875rem
}
.form__input {
 -webkit-box-flex:1;
 -ms-flex:1;
 flex:1
}
.login {
 color:#eee
}
.login label,
.login input[type=text],
.login input[type=password],
.login input[type=submit] {
 border-radius:.25rem;
 padding:16px;
 padding:1rem
}
.login label {
 background-color:#363b41;
 border-bottom-right-radius:0;
 border-top-right-radius:0;
 padding-left:20px;
 padding-left:1.25rem;
 padding-right:20px;
 padding-right:1.25rem
}
.login input[type=password],
.login input[type=text] {
 background-color:#3b4148;
 border-bottom-left-radius:0;
 border-top-left-radius:0
}
.login input[type=password]:focus,
.login input[type=password]:hover,
.login input[type=text]:focus,
.login input[type=text]:hover {
 background-color:#434a52
}
.login input[type=submit] {
 background-color:#ea4c88;
 color:#eee;
 font-weight:700;
 text-transform:uppercase
}
.login input[type=submit]:focus,
.login input[type=submit]:hover {
 background-color:#d44179
}
p {
 margin-bottom:24px;
 margin-bottom:1.5rem;
 margin-top:24px;
 margin-top:1.5rem
}
.text--center {
 text-align:center
}

</style>