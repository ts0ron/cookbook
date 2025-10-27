import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

// https://vite.dev/config/
export default defineConfig({
  plugins: [react()],
  server: {
    host: '127.0.0.1',
    port: parseInt(process.env.FRONTEND_PORT || '3000', 10),
    proxy: {
      '/hello': {
        target: process.env.VITE_API_BASE_URL || `http://localhost:${process.env.BACKEND_PORT || '8014'}`,
        changeOrigin: true,
      },
    },
  },
})
