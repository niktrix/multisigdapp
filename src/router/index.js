import Vue from 'vue'
import Router from 'vue-router'
import Dashboard from '@/components/Dashboard'
import 'vuetify/dist/vuetify.min.css' // Ensure you are using css-loader

// import Signup from '@/components/Signup'
Vue.use(Router)

export default new Router({
  routes: [
    {
      path: '/',
      name: 'dashboard',
      component: Dashboard
    }
    // {
    //   path: '/signup',
    //   name: 'signup',
    //   component: Signup
    // }
  ]
})
