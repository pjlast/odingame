package main

import rl "vendor:raylib"

main :: proc() {
	rl.InitWindow(800, 450, "raylib [core] example - basic window")

	squarePos: rl.Vector2 = {20.0, 20.0}
	speed :: 100

	movement: rl.Vector2 = {0.0, 0.0}

	for !rl.WindowShouldClose() {
		movement = {0.0, 0.0}

		if rl.IsKeyDown(rl.KeyboardKey.RIGHT) {
			movement.x += 1
		}
		if rl.IsKeyDown(rl.KeyboardKey.LEFT) {
			movement.x += -1
		}
		if rl.IsKeyDown(rl.KeyboardKey.UP) {
			movement.y += -1
		}
		if rl.IsKeyDown(rl.KeyboardKey.DOWN) {
			movement.y += 1
		}

		movement = rl.Vector2Normalize(movement)
		squarePos += movement * speed * rl.GetFrameTime()

		rl.BeginDrawing()

		rl.ClearBackground(rl.RAYWHITE)

		rl.DrawText("Congrats! You created your first window!", 190, 200, 20, rl.LIGHTGRAY)
		rl.DrawRectangle(i32(squarePos.x), i32(squarePos.y), 20, 20, rl.RED)

		rl.EndDrawing()
	}

	rl.CloseWindow()
}
