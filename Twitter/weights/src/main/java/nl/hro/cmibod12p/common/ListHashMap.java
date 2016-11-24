package nl.hro.cmibod12p.common;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class ListHashMap<K, V> extends MapWrapper<K, List<V>> implements ListMap<K, V> {
	public ListHashMap() {
		super(new HashMap<>());
	}

	public ListHashMap(Map<K, List<V>> map) {
		super(new HashMap<>(map));
	}

	@Override
	public V getFirst(K key) {
		List<V> value = get(key);
		if(value != null && !value.isEmpty()) {
			return value.iterator().next();
		}
		return null;
	}

	public boolean add(K key, V value) {
		List<V> values = get(key);
		if(values == null) {
			values = new ArrayList<>();
			put(key, values);
		}
		return values.add(value);
	}
}
