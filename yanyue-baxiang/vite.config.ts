import { defineConfig } from 'vite';

export default defineConfig({
  base: './',
  server: { port: 8080, open: false },
  build: { target: 'es2020', chunkSizeWarningLimit: 1500 },
});
