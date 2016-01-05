/*This script contains all the function to control input data.*/
function check_date(){
    /*Check the user not insert wrong character.*/
    $("input[type='date']").keypress(function(e){
        if(e.keyCode == 0){
            if((e.key < "0" || e.key > "9") && e.key != "-"){
                $("input[name='insert']").attr("disabled", true);
                $("#error_input_message").text("La data deve essere nel formato yyyy-mm-dd.");
            }
        }
    });
    
    /*Check the date be right after deleting text.*/
    $("input[type='date']").keyup(function(e){
        if(e.keyCode == 8 || e.keyCode == 46){
            if(!/[^0-9\-]/.test($(this).val())){
                $("input[name='insert']").removeAttr("disabled");
                $("#error_input_message").empty();
            }
        }
    });
    
    /*Check the date be right after deleting text.*/
    $("input[type='date']").focusout(function(e){
        if(/\d\d\d\d-\d\d-\d\d/.test($(this).val())){
            $("input[name='insert']").removeAttr("disabled");
            $("#error_input_message").empty();
        }
        else{
            $("input[name='insert']").attr("disabled", true);
            $("#error_input_message").text("La data deve essere nel formato yyyy-mm-dd.");
        }
    });
}

function control_customers_input(){
    /*Disable submit button if a not-letter was inserted.*/
    $("input[type='text']").keypress(function(e){
        if(e.keyCode == 0){
            if((e.key < "a" || e.key > "z") && (e.key < "A" || e.key > "Z") && e.key != " " && e.key != ","){
                $("input[name='insert']").attr("disabled", true);
                $("#error_input_message").text("E' possibile inserire solo caratteri lettera (maiuscola e minuscola), \n\
                                                spazio e virgola.")
            }
        }
    });
    
    /*When the user deletes text, control if the string is correct.*/
    $("input[type='text']").keyup(function(e){
        if(e.keyCode == 8 || e.keyCode == 46){
            if(!/[^a-zA-Z ,]/.test($(this).val())){
                $("input[name='insert']").removeAttr("disabled");
                $("#error_input_message").empty();
            }
        }
    });
    
    /*Check the date be right.*/
    check_date();
}

function control_vehicles_input(){
    /*Disable submit button if the license plate is wrong.*/
    $("input[name='targa']").keypress(function(e){
        if(e.keyCode == 0){
            if((e.key < "A" || e.key > "Z") && (e.key < "0" || e.key > "9")){
                $("input[name='insert']").attr("disabled", true);
                $("#error_input_message").text("La targa deve essere composta da lettere maisucole e numeri.");
            }
        }
    });
    
    /*Enable submit button if the license plate is right after deleting text.*/
    $("input[name='marca']").keyup(function(e){
        if(e.keyCode == 8 || e.keyCode == 46){
            if(!/[^A-Za-z1-9]/.test($(this).val())){
                $("input[name='insert']").removeAttr("disabled");
                $("#error_input_message").empty();
            }
        }
    });
    
    /*Disable submit button if the brand is wrong.*/
    $("input[name='marca']").keypress(function(e){
        if(e.keyCode == 0){
            if((e.key < "A" || e.key > "Z") && (e.key < "a" || e.key > "z") && (e.key < "0" || e.key > "9") && e.key != " "){
                $("input[name='insert']").attr("disabled", true);
                $("#error_input_message").text("La marca deve contenere solo caratteri lettera (maiuscola e minuscola) e spazio.")
            }
        }
    });
    
    /*Enable submit button if the brand is right after deleting text.*/
    $("input[name='targa']").keyup(function(e){
        if(e.keyCode == 8 || e.keyCode == 46){
            if(!/[^A-Z1-9 ]/.test($(this).val())){
                $("input[name='insert']").removeAttr("disabled");
                $("#error_input_message").empty();
            }
        }
    });
    
    /*Check the year be right.*/
    $("input[name='annoRegistrazione']").keypress(function(e){
        if(e.keyCode == 0){
            if(e.key < "0" || e.key > "9" || $(this).val().length > 3){
                $("input[name='insert']").attr("disabled", true);
                $("#error_input_message").text("L'anno deve contenere 4 numeri.")
            }
        }
    });
    
    /*Check the date be right after deleting text.*/
    $("input[name='annoRegistrazione']").keyup(function(e){
        if(e.keyCode == 8 || e.keyCode == 46){
            if(!/[^0-9]/.test($(this).val()) && $(this).val().length <= 4){
                $("input[name='insert']").removeAttr("disabled");
                $("#error_input_message").empty();
            }
        }
    });
}

function control_customers_input(){
    /*Disable submit button if the driving license is wrong.*/
    $("input[name='patente']").keypress(function(e){
        if(e.keyCode == 0){
            if((e.key < "A" || e.key > "Z") && (e.key < "0" || e.key > "9")){
                $("input[name='insert']").attr("disabled", true);
                $("#error_input_message").text("La patente deve essere composta da lettere maisucole e numeri.");
            }
        }
    });
    
    /*Enable submit button if the driving license is right after deleting text.*/
    $("input[name='patente']").keyup(function(e){
        if(e.keyCode == 8 || e.keyCode == 46){
            if(!/[^A-Za-z1-9]/.test($(this).val())){
                $("input[name='insert']").removeAttr("disabled");
                $("#error_input_message").empty();
            }
        }
    });
    
    /*Disable submit button if a not-letter was inserted.*/
    $("input[name='nome'], input[name='cognome']").keypress(function(e){
        if(e.keyCode == 0){
            if((e.key < "a" || e.key > "z") && (e.key < "A" || e.key > "Z") && e.key != " "){
                $("input[name='insert']").attr("disabled", true);
                $("#error_input_message").text("Il nome non può contenere caratteri che non siano lettere o spazi.")
            }
        }
    });
    
    /*When the user deletes text, control if the string is correct.*/
    $("input[name='nome'], input[name='cognome']").keyup(function(e){
        if(e.keyCode == 8 || e.keyCode == 46){
            if(!/[^a-zA-Z ]/.test($(this).val())){
                $("input[name='insert']").removeAttr("disabled");
                $("#error_input_message").empty();
            }
        }
    });
}

