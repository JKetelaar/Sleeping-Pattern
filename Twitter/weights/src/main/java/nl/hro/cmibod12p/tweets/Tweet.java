package nl.hro.cmibod12p.tweets;

public class Tweet implements Comparable<Tweet> {
	private static final int MINUTE = 60;
	private static final int HOUR = 60 * MINUTE;
	private final int time;
	private final String tweet;

	public Tweet(int time, String tweet) {
		this.time = time;
		this.tweet = tweet.toLowerCase();
	}

	public int getTime() {
		return time;
	}

	public String getTweet() {
		return tweet;
	}

	@Override
	public String toString() {
		int hour = time / HOUR;
		int minute = (time / MINUTE) % 60;
		int second = time % 60;
		StringBuilder sb = new StringBuilder();
		if(hour < 10) {
			sb.append('0');
		}
		sb.append(hour).append(':');
		if(minute < 10) {
			sb.append('0');
		}
		sb.append(minute).append(':');
		if(second < 10) {
			sb.append('0');
		}
		return sb.append(second).append(' ').append(tweet).toString();
	}

	@Override
	public int compareTo(Tweet o) {
		return time - o.time;
	}
}
