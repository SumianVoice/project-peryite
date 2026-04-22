
function amnv_game.is_box_point_overlap(a, b, p)
	return (
		p.x >= a.x and p.x <= b.x and
		p.y >= a.y and p.y <= b.y and
		p.z >= a.z and p.z <= b.z
	)
end
-- minp maxp, minp maxp
function amnv_game.is_box_overlap(min1, max1, min2, max2)
	return (
		min1.x < max2.x and max1.x > min2.x and
		min1.y < max2.y and max1.y > min2.y and
		min1.z < max2.z and max1.z > min2.z
	)
end
