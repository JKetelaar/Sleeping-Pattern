package nl.hro.cmibod12p.tweets;

import java.io.BufferedInputStream;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.util.Arrays;
import java.util.HashSet;
import java.util.Set;

import org.json.JSONArray;
import org.json.JSONObject;
import org.json.JSONTokener;

public class Main {
	public static void main(String[] args) throws Exception {
		if(args.length < 2) {
			System.out.println("Usage: [config.json] [settings.json]");
			System.exit(1);
		}
		JSONObject config = jsonFromFile(args[0]);
		JSONObject settings = jsonFromFile(args[1]);
		try(Connection connection = connectToDatabase(config)) {
			calculateWeights(config, settings, connection);
		}
	}

	private static JSONObject jsonFromFile(String fileName) throws IOException {
		try(InputStream input = new BufferedInputStream(new FileInputStream(fileName))) {
			return new JSONObject(new JSONTokener(input));
		}
	}

	private static Connection connectToDatabase(JSONObject config) throws SQLException {
		JSONObject mysql = config.getJSONObject("mysql");
		return DriverManager.getConnection("jdbc:mysql://" + mysql.getString("host") + "/" + mysql.getString("database"), mysql.getString("user"), mysql.getString("password"));
	}

	private static void calculateWeights(JSONObject config, JSONObject settings, Connection connection) throws SQLException {
		JSONArray countries = settings.getJSONArray("countries");
		for(int i = 0; i < countries.length(); i++) {
			JSONObject country = countries.getJSONObject(i);
			new TweetAnalyser(connection, getTerms(country)).run(false);
		}
	}

	private static Set<String> getTerms(JSONObject country) {
		JSONArray terms = country.getJSONArray("twitterTerms");
		return new HashSet<>(Arrays.asList(terms.toList().toArray(new String[terms.length()])));
	}
}
