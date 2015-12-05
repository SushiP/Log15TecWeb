/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package log15;

import javax.servlet.http.Cookie;
import javax.servlet.http.HttpServletResponse;
/**
 *
 * @author Giulio
 */
public class WebUtility {
    
    public String navigationBarAdmin(int selected){
        String bar = "<nav>";
        String[] buttonsClass = {"", "", "", ""}; 
        
        buttonsClass[selected] = "class='selected'";
        
        bar += "<button id='gestisci_veicoli'" + buttonsClass[0] + " onclick='location.href=\"#\";'>Gestisci Veicoli</button>";
        bar += "<button id='gestisci_autisti'" + buttonsClass[1] + " onclick='location.href=\"#\";'>Gestisci Autisti</button>";
        bar += "<button id='gestisci_clienti'" + buttonsClass[2] + " onclick='location.href=\"#\";'>Gestisci Clienti</button>";
        bar += "<button id='gestisci_assegnamenti'" + buttonsClass[3] + " onclick='location.href=\"#\";'>Gestisci Assegnamenti</button>";
        
        bar += "</nav>";
        return bar;
    }
}
