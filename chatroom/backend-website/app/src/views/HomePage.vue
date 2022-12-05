<template>
  <div>
    <div
      class="app-container"
      :class="{ 'app-mobile': isDevice, 'app-mobile-dark': theme === 'dark' }"
    >
      <chat-container
        v-if="showChat"
        :current-user-id="currentUserId"
        :theme="theme"
        :is-device="isDevice"
      />
    </div>
  </div>
</template>

<script>
import ChatContainer from "../ChatContainer.vue";
const axios = require("axios").default;
const qs = require("qs");
import router from "@/router";

export default {
  components: {
    ChatContainer,
  },

  data() {
    return {
      theme: "dark",
      showChat: false,
      rooms: [],
      messages: [],
      currentUserId: this.$route.params.userId,
      isDevice: false,
    };
  },

  mounted() {
    document.body.classList.add("home");

    const ogg = this;
    this.isDevice = window.innerWidth < 500;
    window.addEventListener("resize", (ev) => {
      if (ev.isTrusted) this.isDevice = window.innerWidth < 500;
    });

    const value = `; ${document.cookie}`;
    const parts = value.split(`; Authorization=`);
    const token = parts[1];

    axios
      .post(
        "http://localhost:3080/api/authenticate",
        qs.stringify({
          Authorization: token,
        })
      )
      .then(function (res) {
        console.log(res.data);
        if (res.data.message == "Authentication OK!") {
          ogg.showChat = true;
        } else {
          router.push({ name: "Register" });
        }
      });
  },
  unmounted() {
    document.body.classList.remove("home");
  },
};
</script>

<style lang="scss">
.home {
  margin: 0;
  height: 100%;
}
.app-container {
	font-family: 'Quicksand', sans-serif;
}
.app-mobile {
	padding: 0;
	&.app-mobile-dark {
		background: #131415;
	}
	.user-logged {
		margin: 10px 5px 0 10px;
	}
	select {
		margin: 10px 0;
	}
	.button-theme {
		margin: 10px 10px 0 0;
	}
}
.button-theme {
	float: right;
	display: flex;
	align-items: center;
	.button-light {
		background: #fff;
		border: 1px solid #46484e;
		color: #46484e;
	}
	.button-dark {
		background: #1c1d21;
		border: 1px solid #1c1d21;
	}
	button {
		color: #fff;
		outline: none;
		cursor: pointer;
		border-radius: 4px;
		padding: 6px 12px;
		margin-left: 10px;
		border: none;
		font-size: 14px;
		transition: 0.3s;
		vertical-align: middle;
		&.button-github {
			height: 30px;
			background: none;
			padding: 0;
			margin-left: 20px;
			img {
				height: 30px;
			}
		}
		&:hover {
			opacity: 0.8;
		}
		&:active {
			opacity: 0.6;
		}
		@media only screen and (max-width: 768px) {
			padding: 3px 6px;
			font-size: 13px;
		}
	}
}

</style>