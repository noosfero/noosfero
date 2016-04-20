var all_users_radio_btn = document.getElementById("send_to_all");
var admins_radio_btn = document.getElementById("send_to_admins");
var env_admins_checkbox = document.getElementById("env_admins");
var profile_admins_checkbox = document.getElementById("profile_admins");

admins_radio_btn.onchange = function() {
    change_checkbox_state("admins");
};

all_users_radio_btn.onchange = function() {
    change_checkbox_state("all_users");
};

function change_checkbox_state (recipients) {
    if(recipients == "all_users"){
        env_admins_checkbox.disabled = true;
        profile_admins_checkbox.disabled = true;
    }else {
        env_admins_checkbox.disabled = false;
        profile_admins_checkbox.disabled = false;
    }
};
