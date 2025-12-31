# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

MindMush is a Rails 7 game platform where users play and create AI-generated HTML5 Canvas mini-games. Games are JavaScript objects executed on a 400x400 canvas with click/touch controls, typically 20-120 seconds duration.

## Development Commands

```bash
# Start development server (runs Rails, JS bundler, CSS watcher)
bin/dev

# Individual processes
bin/rails server              # Rails only (port 3000)
yarn build --watch            # JavaScript bundler (esbuild)
yarn build:css --watch        # Tailwind CSS

# Database
bin/rails db:create db:migrate
bin/rails db:seed             # Load predefined games

# Tests
bin/rails test                # All tests
bin/rails test test/models/game_test.rb              # Single file
bin/rails test test/models/game_test.rb:10           # Single test (line number)

# Console
bin/rails console

# Make a user admin
bin/rails runner "User.find_by(username: 'username').update(admin: true)"
```

## Architecture

### Tech Stack
- Ruby 3.3.5 / Rails 7.1.6
- PostgreSQL
- Devise (authentication)
- Hotwire (Turbo + Stimulus)
- esbuild + Tailwind CSS 4
- Groq API (LLaMA 3.3 70B) for game generation

### Key Services

**`app/services/groq_client.rb`** - HTTP wrapper for Groq API. Requires `Rails.application.credentials.groq[:api_key]`.

**`app/services/game_generator.rb`** - Orchestrates AI game creation with strict prompt rules defining the game object structure (init, start, tick, handleClick, render, end methods).

### Game Object Structure

All games must follow this interface:
```javascript
const game = {
  config: { duration: 20 },
  state: { score: 0, isRunning: false, timeLeft: 20 },
  canvas: null, ctx: null, timer: null,
  onScoreUpdate: null, onGameEnd: null,
  init(canvas) { },  // Setup canvas and event listeners
  start() { },       // Reset state, start timer
  tick() { },        // Called every second
  handleClick(e) { }, // Click/touch handler
  render() { },      // Draw to canvas
  end() { }          // Cleanup, trigger onGameEnd callback
};
```

Canvas: 400x400px. Colors: `#1a1a2e` (bg), `#e94560` (pink), `#8b2fc9` (purple), `#ffffff` (white).

### Stimulus Controllers

- **`game_controller.js`** - Game playback. Executes game code via `new Function()`, handles score saving with CSRF.
- **`generator_controller.js`** - AI game generation UI with preview/test functionality.
- **`flash_controller.js`** - Toast notifications with auto-dismiss and slide animations.
- **`confirm_controller.js`** - Custom styled confirmation modal replacing browser alerts.

### Database Models

- **User** - Devise authentication, has `admin` boolean, `username`, `total_score`, `games_played`
- **Game** - Has slug, code (JS), game_type (predefined/ai_generated), status (pending/trial/approved/rejected/archived), metrics (play_count, likes_count, etc.)
- **GameSession** - Play history with score, duration, completion tracking
- **Vote** - Like/dislike (value: 1 or -1), belongs to user and game
- **Report** - Content moderation with reason (inappropriate/broken/offensive/spam/other); auto-archives game after 5 reports
- **Tag/GameTag** - Categorization

### Routes

**Public:**
- `GET /` - Home page
- `GET /games` - Games index
- `GET /games/:slug` - Play a game
- `GET /games/random` - Random game
- `POST /games/:id/play` - Save score

**Authenticated:**
- `GET /profile` - Current user profile
- `GET /u/:username` - User profile by username
- `GET /generator` - Game creation form
- `POST /generator/preview` - Generate game via AI
- `POST /generator/create` - Save generated game
- `POST /games/:id/vote` - Vote (like/dislike)
- `DELETE /games/:id/vote` - Remove vote
- `POST /games/:id/report` - Report a game

**Admin (`/admin`):**
- `GET /admin` - Dashboard with stats
- `GET /admin/games` - Manage games (approve/reject/delete)
- `POST /admin/games/:id/approve` - Approve game
- `POST /admin/games/:id/reject` - Reject game
- `GET /admin/reports` - Manage reports
- `POST /admin/reports/:id/dismiss` - Dismiss report
- `POST /admin/reports/:id/action_taken` - Mark as actioned

### UI/Styling

- Dark theme with slate colors (`bg-slate-950`, `bg-slate-900`, `bg-slate-800`)
- Accent colors: rose (`text-rose-400`) and violet (`text-violet-400`, `text-violet-500`)
- Gradient buttons: `from-violet-500 to-fuchsia-500` or `from-rose-500 to-violet-500`
- Cards: `bg-slate-800/50 rounded-2xl border border-slate-700`
- Inputs: `bg-slate-900/50 border border-slate-600 rounded-lg`

### Devise Views

Custom styled views in `app/views/devise/`:
- Compact forms with `max-w-sm`
- Centered buttons with fixed width
- Consistent spacing with `mt-8` from navbar

## Credentials

Groq API key must be set in Rails credentials:
```bash
bin/rails credentials:edit
# Add: groq:
#        api_key: your_key_here
```
