;injection for the new input code
;starting at B056E, all the way to B058F
;this is a total of 34 bytes

	jmp $305FC ;injection site 6 bytes
	nop ;total 8 bytes
	nop ;total 10 bytes
	nop ;total 12 bytes
	nop ;14
	nop ;16
	nop ;18
	nop ;20
	nop ;22
	nop ;24
	nop ;26
	nop ;28
	nop ;30
	nop ;32
	nop ;34 - corresponds to B0590-1