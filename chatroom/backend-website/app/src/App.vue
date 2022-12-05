<template>
	<div id="app">
		<router-view />
	</div>
</template>

<script>
	export default {
		name: 'app',
		
	}
</script>

<style>
	body {
		background: #fafafa;
		margin: 0;
	}
	input {
		-webkit-appearance: none;
	}
	#app {
		width: 100%;
		padding: 0;
	}
	router-view {
		width: 100%;
		height: 100%;
		top: 0;
		left: 0;
	}
	.page-link, .page-link:visited, .page-link:hover, .page-link:active, .page-link:focus {
		outline: 0 none !important;
		border: 0;
	}
	div {
		display: block;
	}
</style>