package com.dienmay.config.cache;

import java.time.Duration;
import java.util.Map;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.cache.Cache;
import org.springframework.cache.CacheManager;
import org.springframework.cache.annotation.EnableCaching;
import org.springframework.cache.annotation.CachingConfigurer;
import org.springframework.cache.interceptor.CacheErrorHandler;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.data.redis.cache.RedisCacheConfiguration;
import org.springframework.data.redis.cache.RedisCacheManager;
import org.springframework.data.redis.connection.RedisConnectionFactory;
import org.springframework.data.redis.serializer.JdkSerializationRedisSerializer;
import org.springframework.data.redis.serializer.RedisSerializationContext;

@Configuration
@EnableCaching
public class RedisCacheConfig implements CachingConfigurer {
	private static final Logger log = LoggerFactory.getLogger(RedisCacheConfig.class);
	private final RedisConnectionFactory connectionFactory;

	public RedisCacheConfig(RedisConnectionFactory connectionFactory) {
		this.connectionFactory = connectionFactory;
	}

	@Bean
	@Override
	public CacheManager cacheManager() {
		RedisCacheConfiguration defaults = RedisCacheConfiguration.defaultCacheConfig()
				.serializeValuesWith(RedisSerializationContext.SerializationPair
						.fromSerializer(new JdkSerializationRedisSerializer()))
				.disableCachingNullValues();

		Map<String, RedisCacheConfiguration> caches = Map.of(
				"customerHomeCategories", defaults.entryTtl(Duration.ofMinutes(10)),
				"customerHomeProducts", defaults.entryTtl(Duration.ofMinutes(1)),
				"customerProductDetails", defaults.entryTtl(Duration.ofMinutes(2)),
				"customerCatalogPages", defaults.entryTtl(Duration.ofSeconds(30)),
				"customerBrands", defaults.entryTtl(Duration.ofMinutes(10)),
				"customerBranches", defaults.entryTtl(Duration.ofMinutes(2)));

		return RedisCacheManager.builder(connectionFactory)
				.cacheDefaults(defaults.entryTtl(Duration.ofMinutes(1)))
				.withInitialCacheConfigurations(caches)
				.transactionAware()
				.build();
	}

	@Bean
	@Override
	public CacheErrorHandler errorHandler() {
		return new CacheErrorHandler() {
			@Override
			public void handleCacheGetError(RuntimeException exception, Cache cache, Object key) {
				log.warn("Redis cache read failed for {}. Continuing with the database: {}",
						cache.getName(), exception.getMessage());
			}

			@Override
			public void handleCachePutError(RuntimeException exception, Cache cache, Object key, Object value) {
				log.warn("Redis cache write failed for {}: {}", cache.getName(), exception.getMessage());
			}

			@Override
			public void handleCacheEvictError(RuntimeException exception, Cache cache, Object key) {
				log.warn("Redis cache eviction failed for {}: {}", cache.getName(), exception.getMessage());
			}

			@Override
			public void handleCacheClearError(RuntimeException exception, Cache cache) {
				log.warn("Redis cache clear failed for {}: {}", cache.getName(), exception.getMessage());
			}
		};
	}
}
