package nl.hro.cmibod12p.tweets;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import java.util.Map.Entry;
import java.util.Set;

import nl.hro.cmibod12p.common.ListHashMap;
import nl.hro.cmibod12p.common.ListMap;

public class TweetAnalyser {
	private static final int DAY = 86400;
	private final Connection connection;
	private final Set<String> terms;

	public TweetAnalyser(Connection connection, Set<String> terms) {
		this.connection = connection;
		this.terms = terms;
	}

	public void run(boolean countRetweets) throws SQLException {
		ListMap<String, Tweet> tweets = new ListHashMap<>();
		try(PreparedStatement statement = connection.prepareStatement("SELECT `date`, `tweet` FROM `tweets` WHERE `retweet` = ?")) {
			statement.setBoolean(1, countRetweets);
			ResultSet result = statement.executeQuery();
			while(result.next()) {
				aggregate(result.getLong(1), result.getString(2), tweets);
			}
		}
		analyse(tweets);
	}

	private void aggregate(long date, String message, ListMap<String, Tweet> tweets) {
		int time = (int) (date % DAY);
		Tweet tweet = new Tweet(time, message);
		for(String term : terms) {
			if(message.contains(term)) {
				tweets.add(term, tweet);
			}
		}
	}

	private void analyse(ListMap<String, Tweet> tweets) {
		List<Tweet> means = new ArrayList<>(terms.size());
		for(Entry<String, List<Tweet>> entry : tweets.entrySet()) {
			long mean = 0;
			for(Tweet tweet : entry.getValue()) {
				mean += tweet.getTime();
			}
			means.add(new Tweet((int) (mean / entry.getValue().size()), entry.getKey()));
		}
		means.sort(null);
		int min = means.get(0).getTime();
		int max = means.get(means.size() - 1).getTime();
		double delta = (max - min) / -2.0;
		for(Tweet term : means) {
			double mult = (term.getTime() - min) / delta + 1;
			System.out.println(mult + " " + term.getTweet());
		}
	}
}
