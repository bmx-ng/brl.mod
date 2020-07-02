SuperStrict

Framework brl.standardio
Import brl.quaternion
Import BRL.MaxUnit

New TTestSuite.run()

Type SQuatDTest Extends TTest

	Const x:Double = 2
	Const y:Double = 3
	Const z:Double = 4
	Const w:Double = 5

	Method testNew() { test }
		Local q:SQuatD = New SQuatD
		assertEquals(0, q.x)
		assertEquals(0, q.y)
		assertEquals(0, q.z)
		assertEquals(1, q.w)

		q = New SQuatD(x, y, z, w)
		assertEquals(x, q.x)
		assertEquals(y, q.y)
		assertEquals(z, q.z)
		assertEquals(w, q.w)
	End Method

	Method testAngleTo() { test }
	
		Local q1:SQuatD = New SQuatD()
		Local q2:SQuatD = SQuatD.CreateFromEuler(New SVec3D(0, 180, 0))
		Local q3:SQuatD = SQuatD.CreateFromEuler(New SVec3D(0, 360, 0))

		assertEquals(0, q1.AngleTo(q1))
		assertEquals(180, q1.AngleTo(q2), 0.000001)
		assertEquals(0, q1.AngleTo(q3))
	
	End Method
	
	Method testCreateFromEuler() { test }
	
		Local angles:SVec3D[] = [New SVec3D(45, 0, 0), New SVec3D(0, 45, 0), New SVec3D(0, 0, 45)]
	
		For Local order:ERotationOrder = EachIn ERotationOrder.Values()
		
			For Local i:Int = 0 Until angles.length
			
				Local quat:SQuatD = SQuatD.CreateFromEuler(angles[i], order)
				Local euler:SVec3D = quat.ToEuler(order)
				
				assertTrue(euler.DistanceTo(angles[i]) < 0.001)
			
			Next
		Next
	
	End Method
	
	Method testCreateFromRotation() { test }
	
		Local q1:SQuatD = New SQuatD
		Local quat:SQuatD = New SQuatD(-9, -2, 3, -4).Normal()
		Local mat:SMat4D = SQuatD.ToMat4(quat)
		
		Local expected:SQuatD = New SQuatD(0.8581163303210332:Double, 0.19069251784911848:Double, -0.2860387767736777:Double, 0.38138503569823695:Double)
		
		Local q2:SQuatD = SQuatD.CreateFromRotation(mat)
		
		assertTrue(Abs(q2.x - expected.x) <= 0.0001)
		assertTrue(Abs(q2.y - expected.y) <= 0.0001)
		assertTrue(Abs(q2.z - expected.z) <= 0.0001)
		assertTrue(Abs(q2.w - expected.w) <= 0.0001)
		
		quat = New SQuatD(-1, -2, 1, -1).Normal()
		mat = SQuatD.ToMat4(quat)
		
		expected:SQuatD = New SQuatD(0.37796447300922714:Double, 0.7559289460184544:Double, -0.37796447300922714:Double, 0.37796447300922714:Double)
		
		q2:SQuatD = SQuatD.CreateFromRotation(mat)

		assertTrue(Abs(q2.x - expected.x) <= 0.0001)
		assertTrue(Abs(q2.y - expected.y) <= 0.0001)
		assertTrue(Abs(q2.z - expected.z) <= 0.0001)
		assertTrue(Abs(q2.w - expected.w) <= 0.0001)

	End Method

	Method testDot() { test }
		
		Local q1:SQuatD = New SQuatD
		Local q2:SQuatD = New SQuatD
		
		assertEquals(1, q1.Dot(q2))
		
		q1 = New SQuatD(1, 2, 3, 1)
		q2 = New SQuatD(3, 2, 1, 1)
		
		assertEquals(11, q1.Dot(q2))

	End Method
	
	Method testNormal() { test }

		Local quat:SQuatD = New SQuatD(x, y, z, w)
		
		assertTrue(quat.Length() <> 1)
		assertTrue(quat.LengthSquared() <> 1)

		quat = quat.Normal()

		assertTrue(quat.Length() = 1)
		assertTrue(quat.LengthSquared() = 1)
		
		quat = New SQuatD(0, 0, 0, 0)
		
		assertTrue(quat.Length() = 0)
		assertTrue(quat.LengthSquared() = 0)
		
		quat = quat.Normal()

		assertTrue(quat.Length() = 1)
		assertTrue(quat.LengthSquared() = 1)

	End Method

End Type

Type SQuatFTest Extends TTest

	Const x:Float = 2
	Const y:Float = 3
	Const z:Float = 4
	Const w:Float = 5

	Method testNew() { test }
		Local q:SQuatF = New SQuatF
		assertEquals(0, q.x)
		assertEquals(0, q.y)
		assertEquals(0, q.z)
		assertEquals(1, q.w)

		q = New SQuatF(x, y, z, w)
		assertEquals(x, q.x)
		assertEquals(y, q.y)
		assertEquals(z, q.z)
		assertEquals(w, q.w)
	End Method

	Method testAngleTo() { test }
	
		Local q1:SQuatF = New SQuatF()
		Local q2:SQuatF = SQuatF.CreateFromEuler(New SVec3F(0, 180, 0))
		Local q3:SQuatF = SQuatF.CreateFromEuler(New SVec3F(0, 360, 0))

		assertEquals(0, q1.AngleTo(q1))
		assertEquals(180, q1.AngleTo(q2), 0.000001)
		assertEquals(0, q1.AngleTo(q3))
	
	End Method
	
	Method testCreateFromEuler() { test }
	
		Local angles:SVec3F[] = [New SVec3F(45, 0, 0), New SVec3F(0, 45, 0), New SVec3F(0, 0, 45)]
	
		For Local order:ERotationOrder = EachIn ERotationOrder.Values()
		
			For Local i:Int = 0 Until angles.length
			
				Local quat:SQuatF = SQuatF.CreateFromEuler(angles[i], order)
				Local euler:SVec3F = quat.ToEuler(order)
				
				assertTrue(euler.DistanceTo(angles[i]) < 0.001)
			
			Next
		Next
	
	End Method
	
	Method testCreateFromRotation() { test }
	
		Local q1:SQuatF = New SQuatF
		Local quat:SQuatF = New SQuatF(-9, -2, 3, -4).Normal()
		Local mat:SMat4F = SQuatF.ToMat4(quat)
		
		Local expected:SQuatF = New SQuatF(0.8581163303210332:Float, 0.19069251784911848:Float, -0.2860387767736777:Float, 0.38138503569823695:Float)
		
		Local q2:SQuatF = SQuatF.CreateFromRotation(mat)
		
		assertTrue(Abs(q2.x - expected.x) <= 0.0001)
		assertTrue(Abs(q2.y - expected.y) <= 0.0001)
		assertTrue(Abs(q2.z - expected.z) <= 0.0001)
		assertTrue(Abs(q2.w - expected.w) <= 0.0001)
		
		quat = New SQuatF(-1, -2, 1, -1).Normal()
		mat = SQuatF.ToMat4(quat)
		
		expected:SQuatF = New SQuatF(0.37796447300922714:Float, 0.7559289460184544:Float, -0.37796447300922714:Float, 0.37796447300922714:Float)
		
		q2:SQuatF = SQuatF.CreateFromRotation(mat)

		assertTrue(Abs(q2.x - expected.x) <= 0.0001)
		assertTrue(Abs(q2.y - expected.y) <= 0.0001)
		assertTrue(Abs(q2.z - expected.z) <= 0.0001)
		assertTrue(Abs(q2.w - expected.w) <= 0.0001)

	End Method

	Method testDot() { test }
		
		Local q1:SQuatF = New SQuatF
		Local q2:SQuatF = New SQuatF
		
		assertEquals(1, q1.Dot(q2))
		
		q1 = New SQuatF(1, 2, 3, 1)
		q2 = New SQuatF(3, 2, 1, 1)
		
		assertEquals(11, q1.Dot(q2))

	End Method
	
	Method testNormal() { test }

		Local quat:SQuatF = New SQuatF(x, y, z, w)

		assertTrue(quat.Length() <> 1)
		assertTrue(quat.LengthSquared() <> 1)

		quat = quat.Normal()

		assertEquals(1, quat.Length(), 0.0001)
		assertEquals(1, quat.LengthSquared(), 0.0001)
		
		quat = New SQuatF(0, 0, 0, 0)
		
		assertTrue(quat.Length() = 0)
		assertTrue(quat.LengthSquared() = 0)
		
		quat = quat.Normal()

		assertEquals(1, quat.Length(), 0.0001)
		assertEquals(1, quat.LengthSquared(), 0.0001)
	
	End Method

End Type

