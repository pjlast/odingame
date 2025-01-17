package main

import "core:math"
import rl "vendor:raylib"

SCREEN_WIDTH :: 800
SCREEN_HEIGHT :: 450

Game_Screen :: enum {
	Title,
	Game,
}

gameScreen := Game_Screen.Title


renderTitle :: proc() -> (shouldClose: bool) {
	@(static) selected_option := 0

	if rl.IsKeyPressed(rl.KeyboardKey.DOWN) do selected_option += 1
	if rl.IsKeyPressed(rl.KeyboardKey.UP)   do selected_option -= 1

	selected_option = min(max(selected_option, 0), 1)

	if rl.IsKeyPressed(rl.KeyboardKey.ENTER) {
		switch selected_option {
		case 0:
			gameScreen = .Game
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

	rotation := 0

	floor := rl.LoadTexture("./floor.png")

	floorPos := rl.Vector2{100, 100}

	for !shouldClose && !rl.WindowShouldClose() {
		switch gameScreen {
		case .Title:
			shouldClose = renderTitle()
		case .Game:
			proc(movement: ^rl.Vector2, squarePos: ^rl.Vector2, floor: rl.Texture2D, floorPos: ^rl.Vector2) {
				movement.x = 0.0
				movement.y = 0.0

				if rl.IsKeyDown(.RIGHT) do movement.x += 1
				if rl.IsKeyDown(.LEFT)  do movement.x -= 1
				if rl.IsKeyDown(.UP)    do movement.y -= 1
				if rl.IsKeyDown(.DOWN)  do movement.y += 1

				if rl.IsKeyPressed(.ENTER) do gameScreen = .Title

				if rl.IsKeyPressed(.Q) {
					floorPos^ = rl.Vector2Rotate(floorPos^ - squarePos^,  math.to_radians(f32(90))) + squarePos^
				}

				normalizedMovement := rl.Vector2Normalize(movement^)
				movement.x = normalizedMovement.x
				movement.y = normalizedMovement.y

				movementDelta := movement^ * speed * rl.GetFrameTime()
				squarePos.x = squarePos.x + movementDelta.x
				squarePos.y = squarePos.y + movementDelta.y

				rl.BeginDrawing()

				rl.ClearBackground(rl.RAYWHITE)

				rl.DrawTexture(floor, i32(floorPos.x - 100), i32(floorPos.y - 100), rl.WHITE)

				rl.DrawText("Congrats! You created your first window!", 190, 200, 20, rl.LIGHTGRAY)
				rl.DrawRectangle(i32(squarePos.x - 10), i32(squarePos.y - 10), 20, 20, rl.RED)

				rl.EndDrawing()
			}(&movement, &squarePos, floor, &floorPos)
		}
	}

	rl.CloseWindow()
}
