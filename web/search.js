function search(inputs, row){
    var parameters = new Array(4);
    var inputs = $(inputs);
    var allNull = false;

    /*Store all the search parameters into array.*/
    for(i = 0; i < inputs.length; i++){
        var val = $(inputs[i]).val();

        if(val != undefined && val != ""){
            parameters[i] = val;
            allNull = true;
        }
        else
            parameters[i] = null;
    }

    /*Select all the rows that contain an effective db row.*/
    $rows = $("." + row);

    /*If the search inputs contain nothings, show all the rows.*/
    if(!allNull)
        $rows.show(1000);
    else{
        /*Scroll all the rows.*/
        for(i = 0; i < $rows.length; i++){
            /*For all the rows, scroll all its children.*/
            $td = $($rows[i]).children();
            to_delete = false;

            /*If a parameter does not match, hide that row.*/
            for(j = 0; j < $td.length; j++)
                if(parameters[j] != null && $($td[j+1]).text().indexOf(parameters[j]) == -1)
                    to_delete = true;

            if(to_delete)
                $($rows[i]).hide('slow');
            else if(!to_delete && $($rows[i]).is(":hidden"))
                $($rows[i]).show('slow');
        }
    }
}


