# CartoonifyAI - Mobile-first demo

This is a minimal starter Flutter app that lets users pick/take a photo and send it to a server to convert it into a cartoon/anime style.

## How to use (phone-only workflow)

1. Open the project in Acode (put this folder under `/sdcard/CartoonifyAI`).
2. Edit `lib/main.dart` to change the server endpoint (https://example.com/api/cartoonify).
3. Commit & push to GitHub (use Termux + git). Example commands:

```bash
cd /sdcard/CartoonifyAI
git init
git add .
git commit -m "initial"
git branch -M main
git remote add origin https://github.com/YOURNAME/CartoonifyAI.git
git push -u origin main
```

4. GitHub Actions will run `flutter build apk` and produce `CartoonifyAI-APK` artifact in the workflow run.

## Notes
- The app currently expects a server that accepts multipart POST with field `file` and returns JSON `{ "result_url": "https://..." }`.
- If you don't have a server, you can temporarily use a placeholder service or implement a simple FastAPI server that runs CartoonGAN/AnimeGAN.

