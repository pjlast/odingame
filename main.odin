package main

import "core:math"
import rl "vendor:raylib"

SCREEN_WIDTH :: 800
SCREEN_HEIGHT :: 450

Game_Screen :: enum {
	TITLE,
	GAME,
}

gameScreen := Game_Screen.TITLE

renderTitle :: proc() -> (shouldClose: bool) {
	@(static) selected_option := 0

	if rl.IsKeyPressed(rl.KeyboardKey.DOWN) {selected_option += 1}
	if rl.IsKeyPressed(rl.KeyboardKey.UP) {selected_option -= 1}

	selected_option = min(max(selected_option, 0), 1)

	if rl.IsKeyPressed(rl.KeyboardKey.ENTER) {
		switch selected_option {
		case 0:
			gameScreen = .GAME
		case 1:
			return true
		}
	}

	rl.BeginDrawing()

	rl.ClearBackground(rl.RAYWHITE)

	rl.DrawText("GAME TITLE", SCREEN_WIDTH / 3, SCREEN_HEIGHT / 3, 30, rl.BLACK)

	rl.DrawText("START GAME", SCREEN_WIDTH / 3, 50 + SCREEN_HEIGHT / 3, 20, rl.BLACK)
	rl.DrawText("EXIT", SCREEN_WIDTH / 3, 80 + SCREEN_HEIGHT / 3, 20, rl.BLACK)

	rl.DrawText(
		">",
		SCREEN_WIDTH / 3 - 20,
		i32(selected_option * 30 + 45 + SCREEN_HEIGHT / 3),
		30,
		rl.BLACK,
	)

	rl.EndDrawing()

	return false
}

main :: proc() {
	rl.InitWindow(SCREEN_WIDTH, SCREEN_HEIGHT, "raylib [core] example - basic window")

	squarePos: rl.Vector2 = {20.0, 20.0}
	speed :: 100

	movement: rl.Vector2 = {0.0, 0.0}

	shouldClose := false

	for !shouldClose && !rl.WindowShouldClose() {
		switch gameScreen {
		case .TITLE:
			shouldClose = renderTitle()
		case .GAME:
			proc(movement: ^rl.Vector2, squarePos: ^rl.Vector2) {
				movement.x = 0.0
				movement.y = 0.0

				if rl.IsKeyDown(.RIGHT) {
					movement.x += 1
				}
				if rl.IsKeyDown(.LEFT) {
					movement.x += -1
				}
				if rl.IsKeyDown(.UP) {
					movement.y += -1
				}
				if rl.IsKeyDown(.DOWN) {
					movement.y += 1
				}

				if rl.IsKeyPressed(.ENTER) {
					gameScreen = .TITLE
				}

				normalizedMovement := rl.Vector2Normalize(movement^)
				movement.x = normalizedMovement.x
				movement.y = normalizedMovement.y

				movementDelta := movement^ * speed * rl.GetFrameTime()
				squarePos.x = squarePos.x + movementDelta.x
				squarePos.y = squarePos.y + movementDelta.y

				rl.BeginDrawing()

				rl.ClearBackground(rl.RAYWHITE)

				rl.DrawText("Congrats! You created your first window!", 190, 200, 20, rl.LIGHTGRAY)
				rl.DrawRectangle(i32(squarePos.x), i32(squarePos.y), 20, 20, rl.RED)

				rl.EndDrawing()
			}(&movement, &squarePos)
		}
	}

	rl.CloseWindow()
}
