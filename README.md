# Bible Apps Website

A modern JAMstack website showcasing our ecosystem of accessible bible study applications.

## Apps Featured

- **Neurodiverse Bible App** - Accessible bible reading for all cognitive abilities
- **Scriptura.AI** - AI-powered scripture research assistant  

## Tech Stack

- Next.js 16 with App Router
- TypeScript
- Tailwind CSS
- Static export ready for JAMstack deployment

## Development

```bash
npm install
npm run dev
```

## Deployment

```bash
npm run build
```

The site exports as static files in the `out/` directory, ready for deployment to any static hosting service.

## Mission

Making scripture accessible to everyone through thoughtful design and innovative technology that serves people of all abilities and learning styles.

## CI/CD Pipeline Active

Automated deployments via GitHub Actions:
- Push to `develop` → deploys to staging
- Push to `main` → deploys to production