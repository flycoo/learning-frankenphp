module example.com/consumer

go 1.25

require example.com/localdep v1.0.0

replace example.com/localdep v1.0.0 => ../localdep-patch
