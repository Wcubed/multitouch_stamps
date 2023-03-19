extends GutTest


var distance_parameters = [
	[Vector2(0., 0.), Vector2(1., 0.), Vector2(1., 1.), Vector3(1.414, 1, 1)],
	[Vector2(1., 1.), Vector2(0., 0.), Vector2(1., 0.), Vector3(1.414, 1, 1)],
	[Vector2(1., 0.), Vector2(1., 1.), Vector2(0., 0.), Vector3(1.414, 1, 1)],
	[Vector2(0., 0.), Vector2(1., 1.), Vector2(1., 0.), Vector3(1.414, 1, 1)],
	[Vector2(1., 0.), Vector2(0., 0.), Vector2(1., 1.), Vector3(1.414, 1, 1)],
	[Vector2(1., 1.), Vector2(1., 0.), Vector2(0., 0.), Vector3(1.414, 1, 1)],
	[Vector2(18.43, 3.25), Vector2(18.33, 7.25), Vector2(16, 7.3), Vector3(2.33, 4., 4.723)],
	[Vector2(9.7, 4.5), Vector2(11.1, 4.3), Vector2(11., 1.9), Vector3(1.41, 2.40, 2.906)],
	[Vector2(11.5, 4.3), Vector2(11.33, 1.9), Vector2(10.15, 4.5), Vector3(1.36, 2.41, 2.85)],
]
func test_distance_calculation(p = use_parameters(distance_parameters)):
	assert_almost_eq(StampDetector.calculate_distances_clockwise(p[0], p[1], p[2]), p[3], Vector3(0.01, 0.01, 0.01))
