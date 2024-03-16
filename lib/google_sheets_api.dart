import 'package:gsheets/gsheets.dart';

class GoogleSheetsApi {
  // create credentials
  static const _credentials = r'''
{
  "type": "service_account",
  "project_id": "flutter-gsheets-417419",
  "private_key_id": "2ee7fd3861acf7d3ad24a51a2ebc8076264a64ac",
  "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQC2qDFBfqWur1ok\nYAxx3saWBUKfelaE9l5fdCo+AjpX61Jf0i+EWH3fE/iA/NaOcvkeeBH+obO5K6RO\nTW5adPgrXrZfStxzHYZlNPRVtmcX+X+yKVkRd8/14dMpkCcK9LHnoecuXkeSroOq\n1t9dqei04Aj9+Eau12CAdWT2/0sMF1JfB/Lav8rTxXzfo6geA6v9tAWxtry158kV\n2GTHoQl/bdlLdHAqhympgFcsyB0u2w+9EatFtMzSKQW9qIzoTskUYM4uiPGL4UvO\neGCZLD8UZYtQ/6nLhgSfPW1wE4NfX70ZBgPaCc321mtd13VLXbC/FO6bZaMU0aQ0\nnQgT9JqTAgMBAAECggEAALgAfg/RoYfJj1pqvMlOaTB+jden9CsZy78HYxSif0AS\nJCIqKJd/ODEr0JxYwnWhI8WqS5LFUmPFPaL5CE5QalpiuY3v+FxwYbnLSTuA2XZN\nUnJ8wuedA4xZYyYmLaBNinhbLt0xqq9RyKcYBwf+dvwwexdc59dyrhlkmxg2v7hs\nvCLA9kZuQmNjqZUScQBdmZPcJAjz1nkf92lzjoCEkicKwPF+MiBZcb8PPfWCZdYy\nTsVACeXmKnCYDVTpUq6NuZKMRBSA4zWTDQVPYCYNeZm8+dQSqAR9TymjepBjJZ4z\ncAtuGXVUr1AGzlb4OTPE3bGcsyfa/OWwk5slsmFkAQKBgQDmO0gcaK/sJuvtVj1j\n1qoY45ahwLbE2eBJaELDQif2h+FNmHLtG/SHWgFg8HaUaWTZpyoSRaMD5ikunjYN\nBlcbZyXMAl1DV7hHlOMnitaGvc6ccgHKLfLTDMM0E7DqdzPeQ3vQqGviCAbDRIM0\nY0jGiTaNADs/eGf/BQ84ZC3EkwKBgQDLGcdZ5CkmG2K4X/h/Uzuje331o15J1Dw5\nxKm8euu1+5K0hhc2coMtaSLgDCUPpvsyXkHmZGQ5TyyvKKNfhzR9WgQhbNAqdoqz\nx2XXwndnSHsB1MvCL8tzp5iUtN3BYXvkGvAU+QxoXwykwd2Q7A9VEf0YKHTq+IAB\npvL78YmSAQKBgQC59fIl+Cz4mut/dWP6q14S4mk915II6E7wHAWo/1uWFmTWLyfM\n+wKE/R8V9MRi1co+v3YM8jBcquBipinUVWWwXZ067kH0bfsL3men/c2PYeprlO57\nJqf27l0RSEJi78t2YJ22iQMyu/bya/lqLDORIS1tsF0qxA+D/cswakJJfwKBgB11\nlcbiI13VpxIbSY4eYo4qAXE5yxlmYX33mq8uHTZ+UR9CO+e34HMbxuU8nbuReuop\nZeGnOipd45tch6X5lJGCFwtKHz+phiDhkVIkcPFYQA9Z8FwwVpBmBOm8+lVscG37\nwksofLY+4zSasiqtMuQiAdYZOCxE8zxKHQCSXmQBAoGBAJLY2XXwcdca9+mouoR0\nevNz1vpg30asaVWSefqirTdCMfiFDkTcLlddgZGy4jEH0dNZ97BQBLDrEB6Z7JJw\nvFaIGzTCyxKGmTatFxC0031ITuCmwE0XdEYA3a676n5BDH3ZKZxtXd/RC/xkuiYY\nbUbHO1X3zow0VUP+d4RqoQpd\n-----END PRIVATE KEY-----\n",
  "client_email": "flutter-gsheet@flutter-gsheets-417419.iam.gserviceaccount.com",
  "client_id": "117667085011802722376",
  "auth_uri": "https://accounts.google.com/o/oauth2/auth",
  "token_uri": "https://oauth2.googleapis.com/token",
  "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
  "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/flutter-gsheet%40flutter-gsheets-417419.iam.gserviceaccount.com",
  "universe_domain": "googleapis.com"
}
  ''';

  // set up & connect to the spreadsheet
  static const _spreadsheetId = '1c-pbdfIPCuCNC8chEcMa85-k1SdQXqwpJ3fzRVLIdTk';
  static final _gsheets = GSheets(_credentials);
  static Worksheet? _worksheet;

  // some variables to keep track of..
  static int numberOfTransactions = 0;
  static List<List<dynamic>> currentTransactions = [];
  static bool loading = true;

  // initialise the spreadsheet!
  Future init() async {
    final ss = await _gsheets.spreadsheet(_spreadsheetId);
    _worksheet = ss.worksheetByTitle('Worksheet1');
    countRows();
  }

  // count the number of notes
  static Future countRows() async {
    while ((await _worksheet!.values
            .value(column: 1, row: numberOfTransactions + 1)) !=
        '') {
      numberOfTransactions++;
    }
    // now we know how many notes to load, now let's load them!
    loadTransactions();
  }

  // load existing notes from the spreadsheet
  static Future loadTransactions() async {
    if (_worksheet == null) return;

    for (int i = 1; i < numberOfTransactions; i++) {
      final String transactionName =
          await _worksheet!.values.value(column: 1, row: i + 1);
      final String transactionAmount =
          await _worksheet!.values.value(column: 2, row: i + 1);
      final String transactionType =
          await _worksheet!.values.value(column: 3, row: i + 1);

      if (currentTransactions.length < numberOfTransactions) {
        currentTransactions.add([
          transactionName,
          transactionAmount,
          transactionType,
        ]);
      }
    }
    print(currentTransactions);
    // this will stop the circular loading indicator
    loading = false;
  }

  // insert a new transaction
  static Future insert(String name, String amount, bool isIncome) async {
    if (_worksheet == null) return;
    numberOfTransactions++;
    currentTransactions.add([
      name,
      amount,
      isIncome == true ? 'income' : 'expense',
    ]);
    await _worksheet!.values.appendRow([
      name,
      amount,
      isIncome == true ? 'income' : 'expense',
    ]);
  }

  // CALCULATE THE TOTAL INCOME!
  static double calculateIncome() {
    double totalIncome = 0;
    for (int i = 0; i < currentTransactions.length; i++) {
      if (currentTransactions[i][2] == 'income') {
        totalIncome += double.parse(currentTransactions[i][1]);
      }
    }
    return totalIncome;
  }

  // CALCULATE THE TOTAL EXPENSE!
  static double calculateExpense() {
    double totalExpense = 0;
    for (int i = 0; i < currentTransactions.length; i++) {
      if (currentTransactions[i][2] == 'expense') {
        totalExpense += double.parse(currentTransactions[i][1]);
      }
    }
    return totalExpense;
  }
}
