.data

;------------------------------------------------------------------------

	two real8 2.0

	a real8 ?
	x real8 ?

	eq1 real8 ?
	eq2 real8 ?

	res real8 ?

.code
public Calculate_Func

;------------------------------------------------------------------------

Calculate_Func proc
	; extern "C" double Calculate_Func(double a, double x);
	; Input: 
	;   a -> XMM0
	;   x -> XMM1
	; Output:
	;   Result -> XMM0

	movsd a, XMM0
	movsd x, XMM1         

	fld a			  
	fdiv two	      ; st(0) = a / 2

	fld x
	fsub st(0), st(1) ; st(0) = st(1) - st(0)    
	fstp st(1)

	fabs              ; st(0) = |st(0)|

	fld1
	fadd			  ; st(0) = st(0) + 1
	
	fld1			
	fxch
	fyl2x
	fldln2
	fmul			 ; st(0) = ln(st(0))

	fstp eq1

	fldpi
	fld a
	fdiv			; st(0) = pi / a

	fld x
	fmul			; st(0) = st(0) * x

	fcos			; st(0) = cos(st(0))

	fstp eq2

	fld x
	fld a
	fdiv			; st(0) = x / a

	fld st(0)

	f2xm1
	fld1
	fadd			; st(0) = 2 ^ st(0)
	
	fadd			; st(0) = st(0) + st(1)

	fld eq1
	fld eq2

	fadd			; st(0) = eq1 + eq2

	fxch

	fdiv			; st(0) = st(1) / st(0)

	fstp res

	movq XMM0, res

	ret

Calculate_Func endp

;------------------------------------------------------------------------

end