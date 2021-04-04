function doGet(e) {
  var spreadsheetId = '1A34zw9PWvOdO5wjCNfEGiYzabHRELYhjsF8ElzPVths';
  try {
    var name = e.parameter.name;
    var feedback = e.parameter.feedback;
    var mail = e.parameter.mail;

    if (feedback == "vs") {
      var sheet = SpreadsheetApp
        .openById(spreadsheetId).getSheetByName("Users");

      var data = sheet.getDataRange().getValues();

      var flag = true
      for (var i = 0; i < data.length; i++) {
        if (data[i][1] == mail) {
          flag = false
          break
        }
      }
      if (flag) {
        var d = new Date();
        var timeStamp = d.toLocaleTimeString();
        var rowDate = sheet.appendRow([name, mail, timeStamp]);

        GmailApp.sendEmail("vlbhartiya@gmail.com", name + " Signed in !", name + " | " + mail + "\n signed up\n Riverto");
        GmailApp.sendEmail(mail, "Thank You for Signing up with Riverto !", "Hello " + name + "," + "\n\nWelcome to world of music!\n\nYou have successfully signed up with Riverto. We hope that you will have a great experience with us.\n\n Happy Streaming !\n\n Team Riverto");
      }
    } else {
      var data = sheet.getDataRange().getValues();
      var d = new Date();
      var timeStamp = d.toLocaleTimeString();
      var rowDate = sheet.appendRow([name, feedback, mail, timeStamp]);
      GmailApp.sendEmail("vlbhartiya@gmail.com", "Feedback from " + name, feedback);

      GmailApp.sendEmail(mail, "Thank you for your feedback", "Hello " + name + ",\n\nWe are greatful for your feedback! It will help us improve your experience with us.\n\nHappy Streaming !\n\nTeam Riverto");
    }


    //    var rowDate = sheet.appendRow([name,mail]);

  } catch (ex) {
    res = -1;
  }

  return ContentService.createTextOutput(JSON.stringify(res)).setMimeType(ContentService.MimeType.JSON);
}
