package com.microsoft.gbb.reddog.virtualcustomers.config;

import org.jobrunr.configuration.JobRunr;
import org.jobrunr.jobs.mappers.JobMapper;
import org.jobrunr.scheduling.JobScheduler;
import org.jobrunr.storage.InMemoryStorageProvider;
import org.jobrunr.storage.StorageProvider;
import org.jobrunr.utils.mapper.jackson.JacksonJsonMapper;
import org.springframework.context.ApplicationContext;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class JobRunrConfiguration {

    @Bean
    public JobMapper jobMapper() {
        return new JobMapper(new JacksonJsonMapper());
    }

    @Bean
    public StorageProvider storageProvider(JobMapper jobMapper) {
        InMemoryStorageProvider storageProvider = new InMemoryStorageProvider();
        storageProvider.setJobMapper(jobMapper);
        return storageProvider;
    }

    @Bean
    public JobScheduler initJobRunr(StorageProvider storageProvider, ApplicationContext applicationContext) {
        return JobRunr.configure()
                .useJobActivator(applicationContext::getBean)
                .useStorageProvider(storageProvider)
                .useBackgroundJobServer()
                .initialize()
                .getJobScheduler();
    }
}
