rollout ZLJTest "烘培方向到顶点"
(
	spinner 'spn2' "通道号" pos:[24,88] width:50 height:16 enabled:true range:[1,8,0] type:#integer scale:0.1 align:#left
	button 'btn1' "OK" pos:[24,112] width:80 height:17 enabled:false align:#left
	dropDownList 'axisList' "局部方向" pos:[24,40] width:100 height:41 items:#("X", "Y", "Z") align:#left
	on spn2 changed val do
	(
	)
	on btn1 pressed  do
	(
	for obj in selection do
		(
		cls=classof(obj);
		if cls==Editable_Poly do
			(			
				axis=obj.transform[axisList.selection]
				polyop.setMapSupport obj spn2.value true
				for i=1 to (polyop.getNumVerts obj) do (polyop.setMapVert obj spn2.value i axis)
			)
		)
	)
)

fn refreshButtonStatus =(
	if (selection.count<1) then(
		ZLJTest.btn1.enabled=false
	
		)
	else(
		found=false
		for n in selection while found==false do(
			if classof(n)==Editable_Poly do(
				found=true
				)
			
			)
		if found==true then ZLJTest.btn1.enabled=true
		else ZLJTest.btn1.enabled=false
		
		)
	)
registerRedrawViewsCallback refreshButtonStatus
addRollout ZLJTest (newrolloutfloater "ZLJ" 200 200)
