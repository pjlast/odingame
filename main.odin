package main

import rl "vendor:raylib"

GameScreen :: enum {
	TITLE,
	GAME,
}

gameScreen := GameScreen.TITLE

renderTitle :: proc() {
	if rl.IsKeyPressed(rl.KeyboardKey.ENTER) {
		gameScreen = .GAME
	}

	rl.BeginDrawing()

	rl.ClearBackground(rl.RAYWHITE)

	rl.DrawText("Congrats! You created your first window!", 190, 200, 20, rl.LIGHTGRAY)

	rl.EndDrawing()
}

main :: proc() {
	rl.InitWindow(800, 450, "raylib [core] example - basic window")

	squarePos: rl.Vector2 = {20.0, 20.0}
	speed :: 100

	movement: rl.Vector2 = {0.0, 0.0}

	for !rl.WindowShouldClose() {
		switch gameScreen {
		case .TITLE:
			renderTitle()
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
