export type Feature = {
  id: string;
  title: string;
  description: string;
  status: "in-development" | "planned" | "considering" | "completed" | "rejected";
  votes: number;
  project?: string;
};

export interface Project {
  id: string;
  name: string;
  description: string;
  features: Feature[];
}

export const projects: Project[] = [
  {
    id: 'tubeflowz',
    name: 'Tubeflowz',
    description: 'YouTube automation tool',
    features: []
  },
  {
    id: 'mediaflowz',
    name: 'Mediaflowz',
    description: 'Social media automation',
    features: []
  },
  {
    id: 'winflowz',
    name: 'Winflowz',
    description: 'Windows automation',
    features: []
  }
]; 
