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
```

## Architecture

### Tech Stack
- Ruby 3.3.5 / Rails 7.1.6
- PostgreSQL
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

### Database Models

- **Game** - Has slug, code (JS), game_type (predefined/ai_generated), status (pending/trial/approved/rejected/archived), metrics (play_count, likes_count, etc.)
- **GameSession** - Play history with score, duration, completion tracking
- **Vote** - Like/dislike (value: 1 or -1)
- **Report** - Content moderation; auto-archives game after 5 reports
- **Tag/GameTag** - Categorization

### Routes

- `GET /games` - Index (top 20 by play count)
- `GET /games/:slug` - Play a game
- `POST /games/:id/play` - Save score (CSRF exempted for API calls)
- `GET /generator/new` - Game creation form
- `POST /generator/preview` - Generate game via AI
- `POST /generator` - Save generated game

## Credentials

Groq API key must be set in Rails credentials:
```bash
bin/rails credentials:edit
# Add: groq:
#        api_key: your_key_here
```
