package main

import "core:fmt"
import "core:math"
import rl "vendor:raylib"
import rlgl "vendor:raylib/rlgl"

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
	if rl.IsKeyPressed(rl.KeyboardKey.UP) do selected_option -= 1

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

DrawTexturePoly :: proc(
	texture: rl.Texture2D,
	origin: rl.Vector2,
	points: []rl.Vector2,
	texCoords: []rl.Vector2,
	tint: rl.Color,
) {
	assert(
		len(points) == len(texCoords),
		"length of points and texture coordinates should be equal",
	)

	rlgl.SetTexture(texture.id)

	rlgl.Begin(rlgl.QUADS)

	rlgl.Color4ub(tint.r, tint.g, tint.b, tint.a)

	for i in 0 ..< (len(points) - 1) {
		rlgl.TexCoord2f(0.5, 0.5)
		rlgl.Vertex2f(origin.x, origin.y)

		rlgl.TexCoord2f(texCoords[i].x, texCoords[i].y)
		rlgl.Vertex2f(points[i].x + origin.x, points[i].y + origin.y)

		rlgl.TexCoord2f(texCoords[i + 1].x, texCoords[i + 1].y)
		rlgl.Vertex2f(points[i + 1].x + origin.x, points[i + 1].y + origin.y)

		rlgl.TexCoord2f(texCoords[i + 1].x, texCoords[i + 1].y)
		rlgl.Vertex2f(points[i + 1].x + origin.x, points[i + 1].y + origin.y)
	}

	rlgl.End()

	rlgl.SetTexture(0)
}

main :: proc() {
	rl.InitWindow(SCREEN_WIDTH, SCREEN_HEIGHT, "raylib [core] example - basic window")

	squarePos: rl.Vector2 = {300.0, 300.0}
	speed :: 100

	movement: rl.Vector2 = {0.0, 0.0}

	shouldClose := false

	rotation := 0

	floor := rl.LoadTexture("./floor.png")
	wall := rl.LoadTexture("./wall.png")
	wall2 := rl.LoadTexture("./wall2.png")
	rl.SetTargetFPS(30)

	floorPos := rl.Vector2{400, 300}
	wallPos := rl.Vector2{400, 150}
	wall2Pos := rl.Vector2{300, 300}

	numRotations := 0
	rotatingRight := false
	rotatingLeft := false

	for !shouldClose && !rl.WindowShouldClose() {
		switch gameScreen {
		case .Title:
			shouldClose = renderTitle()
		case .Game:
			proc(
				movement: ^rl.Vector2,
				squarePos: ^rl.Vector2,
				floor: rl.Texture2D,
				wall: rl.Texture2D,
				wall2: rl.Texture2D,
				floorPos: ^rl.Vector2,
				wallPos: ^rl.Vector2,
				wall2Pos: ^rl.Vector2,
				rotatingRight: ^bool,
				rotatingLeft: ^bool,
				numRotations: ^int,
			) {

				movement.x = 0.0
				movement.y = 0.0

				if rl.IsKeyDown(.RIGHT) do movement.x += 1
				if rl.IsKeyDown(.LEFT) do movement.x -= 1
				if rl.IsKeyDown(.UP) do movement.y -= 1
				if rl.IsKeyDown(.DOWN) do movement.y += 1

				if rl.IsKeyPressed(.ENTER) do gameScreen = .Title

				floorPosRot := floorPos^
				wallPosRot := wallPos^
				wall2PosRot := wall2Pos^
				wallPosRot.y += (f32(numRotations^)/90.0)*50.0
				wallPosRot.x -= (f32(numRotations^)/90.0)*50.0
				wall2PosRot.y -= ((90 - f32(numRotations^))/90.0)*50.0
				wall2PosRot.x -= (f32(numRotations^)/90.0)*50.0
				// wallPosRot = rl.Vector2MoveTowards(wallPosRot, floorPosRot, (f32(numRotations^)/90.0)*50)
				floorPosRot =
					rl.Vector2Rotate(floorPos^ - squarePos^, math.to_radians(f32(numRotations^))) +
					squarePos^
				wallPosRot =
					rl.Vector2Rotate(wallPosRot - squarePos^, math.to_radians(f32(numRotations^))) +
					squarePos^
				wall2PosRot =
					rl.Vector2Rotate(wall2PosRot - squarePos^, math.to_radians(f32(numRotations^))) +
					squarePos^

				if rotatingRight^ {
					numRotations^ += 1
					if numRotations^ == 90 {
						// numRotations^ = 0
						rotatingRight^ = false
					}
				}

				if rotatingLeft^ {
					numRotations^ -= 1
					if numRotations^ == 0 {
						// numRotations^ = 0
						rotatingLeft^ = false
					}
				}


				if rl.IsKeyPressed(.Q) {
					rotatingRight^ = true
					// floorPos^ = rl.Vector2Rotate(floorPos^ - squarePos^,  math.to_radians(f32(90))) + squarePos^
				}

				if rl.IsKeyPressed(.E) {
					rotatingLeft^ = true
					// floorPos^ = rl.Vector2Rotate(floorPos^ - squarePos^,  math.to_radians(f32(-90))) + squarePos^
				}

				normalizedMovement := rl.Vector2Normalize(movement^)
				movement.x = normalizedMovement.x
				movement.y = normalizedMovement.y

				movementDelta := movement^ * speed * rl.GetFrameTime()
				squarePos.x = squarePos.x + movementDelta.x
				squarePos.y = squarePos.y + movementDelta.y

				rl.BeginDrawing()

				rl.ClearBackground(rl.BLACK)

				// rl.DrawTexture(floor, i32(floorPos.x - 100), i32(floorPos.y - 100), rl.WHITE)
				// rl.DrawTextureEx(floor, floorPos^ - [2]f32{100, 100}, f32(numRotations^), 1, rl.WHITE)
				// rl.DrawTexturePro(wall, rl.Rectangle{
				// 		x      = 0,
				// 		y      = 0,
				// 		width  = 200,
				// 		height = 100,
				// 	},
				// rl.Rectangle{
				// 		x      = wallPos.x,
				// 		y      = wallPos.y,
				// 		width  = 200,
				// 		height = 100,
				// 	}, {100, 100}, f32(numRotations^), rl.WHITE)


				texCoords: [5]rl.Vector2 = {
					{0.0, 0.0},
					{0.0, 1.0},
					{1.0, 1.0},
					{1.0, 0.0},
					{0.0, 0.0},
					// {0.0, 0.0},
					// {0.0, 0.0},
					// {1.0, 1.0},
					// {1.0, 0.0},
					// {0.0, 0.0},
				}

				HEIGHT: f32 = 100
				height := HEIGHT * (90.0 - f32(numRotations^)) / 90.0

				points: [5]rl.Vector2 = {
					{-100 - 50*(f32(numRotations^)/90.0), -(height - height / 2)},
					{-100 + 50*(f32(numRotations^)/90.0), (height - height / 2)},
					{100 + 50*(f32(numRotations^)/90.0), (height - height / 2)},
					{100 - 50*(f32(numRotations^)/90.0), -(height - height / 2)},
					{-100 - 50*(f32(numRotations^)/90.0), -(height - height / 2)},
					// {-100, -50},
					// {-100, -50},
					// {100, 50},
					// {100, -50},
					// {-100, -50},
				}

				height2 := HEIGHT * (f32(numRotations^)) / 90.0

				points2: [5]rl.Vector2 = {
					{-(height2 - height2 / 2), 100 - 50*((90 - f32(numRotations^))/90.0)},
					{(height2 - height2 / 2), 100 + 50*((90-f32(numRotations^))/90.0)},
					{(height2 - height2 / 2), -100 + 50*((90 - f32(numRotations^))/90.0)},
					{-(height2 - height2 / 2), -100 - 50*((90 - f32(numRotations^))/90.0)},
					{-(height2 - height2 / 2), 100 - 50*((90 - f32(numRotations^))/90.0)},
					// {-100, -50},
					// {-100, -50},
					// {100, 50},
					// {100, -50},
					// {-100, -50},
				}

				rotatedPoints: [5]rl.Vector2
				for point, i in points {

					rotatedPoints[i] = rl.Vector2Rotate(
						point,
						math.to_radians_f32(f32(numRotations^)),
					)
				}

				rotatedPoints2: [5]rl.Vector2
				for point, i in points2 {

					rotatedPoints2[i] = rl.Vector2Rotate(
						point,
						math.to_radians_f32(f32(numRotations^)),
					)
				}


				// rotatedPoints[0] = rotatedPoints[1] - {0, 100}

				// rotatedPoints[3] = rotatedPoints[1] - {0, 100}
				// rotatedPoints[4] = rotatedPoints[1] - {0, 100}
				// rotatedPoints[6] = rotatedPoints[2] - {0, 100}
				// rotatedPoints[7] = rotatedPoints[1] - {0, 100}


				wall1Col := rl.WHITE
				wall1Col.a = u8(255 * ((90.0 - f32(numRotations^))/90.0))
				wall2Col := rl.WHITE
				wall2Col.a = u8(255 * (f32(numRotations^))/90.0)

				DrawTexturePoly(wall, wallPosRot, rotatedPoints[:], texCoords[:], wall1Col)
				DrawTexturePoly(wall2, wall2PosRot, rotatedPoints2[:], texCoords[:], wall2Col)
				rl.DrawTexturePro(
					floor,
					rl.Rectangle{x = 0, y = 0, width = 200, height = 200},
					rl.Rectangle{x = floorPosRot.x, y = floorPosRot.y, width = 200, height = 200},
					{100, 100},
					f32(numRotations^),
					rl.WHITE,
				)

				rl.DrawRectangle(i32(squarePos.x - 10), i32(squarePos.y - 10), 20, 20, rl.RED)

				rl.EndDrawing()
			}(
				&movement,
				&squarePos,
				floor,
				wall,
				wall2,
				&floorPos,
				&wallPos,
				&wall2Pos,
				&rotatingRight,
				&rotatingLeft,
				&numRotations,
			)
		}
	}

	rl.CloseWindow()
}
