/** @type {import('tailwindcss').Config} */
module.exports = {
  content: [
    "./src/**/*.{js,ts,jsx,tsx,mdx}",
    "./index.html"
  ],
  // tells tailwind that we don't want to use the systems darkmode.
  // enables use of the next-themes package.
  darkMode: "class",
  theme: {
    keyframes:{
      margin:{
        "0%":{
          marginTop:"-0rem"
        },
        "25%":{
          marginTop:"-2.6rem"
        },
        "50%":{
          marginTop:"-4.6rem"
        },
        "75%":{
          marginTop:"-6.6rem"
        }
      },
      progressLoad:{
        "0%":{
          width:"0%"
        },
        "100%":{
          width:"100%"
        }
      }
    },
    animation:{
      margin: "margin 7s linear infinite " ,
      progressLoad:"progressLoad 7s linear infinite"
    }
  },
  // for the great typography
  plugins: [
    require("@tailwindcss/typography")
  ],
}

